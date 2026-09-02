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

# Uses System.Diagnostics.Process directly rather than Start-Process:
# 1) Start-Process -PassThru has a known Windows PowerShell 5.1 bug where
#    .ExitCode comes back empty even after WaitForExit() -- confirmed by
#    direct testing on this machine (a trivial `cmd /c exit 3` still came
#    back as ""). That would make this gate silently misreport pass/fail.
# 2) Redirecting to files (not a pipe / Out-String) avoids a separate hang
#    this machine hit: a stray child dart process kept a pipe handle open,
#    so nothing reading that pipe ever saw EOF.
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $flutterExe
$psi.Arguments = "test"
$psi.UseShellExecute = $false
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.WorkingDirectory = $projectRoot

$proc = [System.Diagnostics.Process]::Start($psi)
$stdoutTask = $proc.StandardOutput.ReadToEndAsync()
$stderrTask = $proc.StandardError.ReadToEndAsync()
$finished = $proc.WaitForExit($timeoutMs)

if (-not $finished) {
    try { $proc.Kill($true) } catch {}
    Get-Process -Name "dart", "dartvm", "dartaotruntime" -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue
    Set-Content -Path $logFile -Value "flutter test timed out after 5 minutes and was killed." -Encoding utf8

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

$stdout = $stdoutTask.GetAwaiter().GetResult()
$stderr = $stderrTask.GetAwaiter().GetResult()
Set-Content -Path $logFile -Value ($stdout + "`n" + $stderr) -Encoding utf8
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
