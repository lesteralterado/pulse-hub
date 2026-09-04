$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$flutterExe = "C:\flutter\bin\flutter.bat"
if (-not (Test-Path $flutterExe)) { $flutterExe = "flutter" }

$stateFile = Join-Path $PSScriptRoot "gate_state.json"
$logFile = Join-Path $PSScriptRoot "last_test_output.log"
$ceiling = 20
$timeoutMs = 8 * 60 * 1000

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

# This repo is sometimes open in more than one concurrent Claude Code
# session (each with its own copy of this Stop hook), and two `flutter
# test` invocations racing at once on this machine reliably breaks one or
# both runs: observed both an instant crash with no error (exit 255) and a
# hung dart.exe that then poisons every subsequent attempt until manually
# killed, since nothing used to clean up a crash's leftovers (only a
# timeout did - see below). A named mutex serializes gate runs across every
# session/process instead of letting them collide. Un-prefixed name = the
# current login session's namespace, which is all we need since both
# sessions run interactively as the same user.
$mutex = New-Object System.Threading.Mutex($false, "PulseHubFlutterTestGate")
$gotLock = $false
try {
    $gotLock = $mutex.WaitOne($timeoutMs + 60000)
} catch [System.Threading.AbandonedMutexException] {
    # Previous holder crashed without releasing; we still got the lock.
    $gotLock = $true
}

if (-not $gotLock) {
    $reason = "Another flutter test gate run (likely a concurrent Claude Code session in this same repo) has been in progress for over 9 minutes. Wait for it to finish rather than starting a new one - running two at once corrupts both."
    @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
    exit 2
}

try {
    # Deliberately NOT using ProcessStartInfo's RedirectStandardOutput/-Error
    # (.NET pipes). On this machine that hung indefinitely: `flutter test`
    # spawns worker processes for each test file, those inherit the pipe
    # handles, and if any of them is slow to release its handle,
    # ReadToEndAsync() waits forever even after the real work is done.
    # Routing through `cmd.exe /c ... > file 2>&1` uses a real file handle
    # instead, which has no such "wait for every handle to close" semantics.
    #
    # --concurrency=1: the default (multiple worker processes racing for CPU
    # and disk) has repeatedly stalled indefinitely on this machine once the
    # suite grew past ~100 tests, most likely OneDrive's background sync
    # competing for I/O over the same files (observed pegging a full CPU core
    # for extended periods). Single-threaded is slower per run but has been
    # reliable where concurrent runs were not; revisit if the project ever
    # moves out of a synced folder.
    # Best-effort only: cmd's `>` redirection below truncates/recreates the
    # file regardless, so a transient lock here (observed: OneDrive syncing
    # it at the exact wrong moment) must not abort the whole gate.
    if (Test-Path $logFile) {
        try { Remove-Item $logFile -Force -ErrorAction Stop } catch {}
    }
    # No quoting here: cmd.exe's `/c` parsing is notoriously unreliable with
    # nested quotes, and none of this project's paths contain spaces.
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/c $flutterExe test --concurrency=1 > $logFile 2>&1"
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

    # A non-zero exit here is often not a real test failure but the same
    # "flutter test crashed mid-run" symptom described above (typically
    # OneDrive I/O contention). Whatever caused it, clean up any worker
    # process it left behind so this crash doesn't poison the next attempt
    # the way it used to before this cleanup existed.
    Get-Process -Name "dart", "dartvm", "dartaotruntime" -ErrorAction SilentlyContinue |
        Stop-Process -Force -ErrorAction SilentlyContinue

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
} finally {
    $mutex.ReleaseMutex()
}
