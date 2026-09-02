$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$flutterExe = "C:\flutter\bin\flutter.bat"
if (-not (Test-Path $flutterExe)) { $flutterExe = "flutter" }

$stateFile = Join-Path $PSScriptRoot "gate_state.json"
$logFile = Join-Path $PSScriptRoot "last_test_output.log"
$ceiling = 20
$timeoutMs = 5 * 60 * 1000

$attempt = 0
if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json
        $attempt = [int]$state.attempt
    } catch {
        $attempt = 0
    }
}

function Save-Attempt($count) {
    Set-Content -Path $stateFile -Value (@{ attempt = $count } | ConvertTo-Json -Compress) -Encoding utf8
}

# Deliberately NOT using ProcessStartInfo's RedirectStandardOutput/-Error
# (.NET pipes). On this machine that hung indefinitely: `flutter test`
# spawns worker processes for each test file, those inherit the pipe
# handles, and if any of them is slow to release its handle,
# ReadToEndAsync() waits forever even after the real work is done.
# Routing through `cmd.exe /c ... > file 2>&1` uses a real file handle
# instead, which has no such "wait for every handle to close" semantics.
if (Test-Path $logFile) { Remove-Item $logFile -Force }
# No quoting here: cmd.exe's `/c` parsing is notoriously unreliable with
# nested quotes, and none of this project's paths contain spaces.
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "cmd.exe"
$psi.Arguments = "/c $flutterExe test > $logFile 2>&1"
$psi.UseShellExecute = $false
$psi.WorkingDirectory = $projectRoot

$proc = [System.Diagnostics.Process]::Start($psi)
$finished = $proc.WaitForExit($timeoutMs)

if (-not $finished) {
    try { $proc.Kill($true) } catch {}
    Get-Process -Name "dart", "dartvm", "dartaotruntime" -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Add-Content -Path $logFile -Value "`n[gate] flutter test timed out after 5 minutes and was killed." -Encoding utf8

    $attempt += 1
    Save-Attempt $attempt

    if ($attempt -gt $ceiling) {
        Write-Output "Gate ceiling reached ($ceiling attempts) - allowing stop despite 'flutter test' timing out. Needs manual investigation, not another retry."
        exit 0
    }

    $reason = "flutter test did not finish within 5 minutes and was killed (attempt $attempt of $ceiling). This looks like a hang, not a normal failure - investigate rather than just retrying."
    @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
    exit 2
}

$testExit = $proc.ExitCode

if ($testExit -eq 0) {
    Save-Attempt 0
    exit 0
}

$attempt += 1
Save-Attempt $attempt

if ($attempt -gt $ceiling) {
    $msg = "Gate ceiling reached ($ceiling failed attempts in a row) - allowing stop despite red 'flutter test'. This needs manual review. See .claude/last_test_output.log for the last failure."
    Write-Output $msg
    exit 0
}

$reason = "flutter test is failing (attempt $attempt of $ceiling). Keep fixing until all tests pass - do not stop or report completion while this gate is red. Full output in .claude/last_test_output.log"
@{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
exit 2
