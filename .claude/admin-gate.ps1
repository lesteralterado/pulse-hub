$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$adminRoot = Join-Path $projectRoot "admin-web"

# No-op until the admin-web Next.js project actually exists, so this hook
# costs the Flutter-only sessions in this repo nothing before/unless the
# Admin Dashboard work has started.
if (-not (Test-Path (Join-Path $adminRoot "package.json"))) {
    exit 0
}

# This repo's .claude/settings.json is shared by every Claude Code session
# working here, and Stop hooks aren't scoped per-session - so without this
# check, a session with zero context on this Next.js codebase (e.g. one
# working the Flutter mobile app) would get forced into the same
# "can't stop, keep fixing" loop as whoever is actually building admin-web,
# for a failure it has no ability to diagnose or fix. That's a deadlock
# risk, not just latency - a peer session flagged exactly this scenario.
# Only the recorded owner session is actually gated; every other session
# gets an informational, non-blocking notice instead.
$ownerFile = Join-Path $PSScriptRoot "admin_gate_owner.json"
$invokerSessionId = $env:CLAUDE_CODE_SESSION_ID

if (Test-Path $ownerFile) {
    try {
        $owner = (Get-Content $ownerFile -Raw | ConvertFrom-Json).ownerSessionId
    } catch {
        $owner = $null
    }

    if ($owner -and $invokerSessionId -and $owner -ne $invokerSessionId) {
        Write-Output "admin-web gate: not blocking - owned by a different session ($owner). See .claude/last_admin_build_output.log for its current status."
        exit 0
    }
}

$stateFile = Join-Path $PSScriptRoot "admin_gate_state.json"
$logFile = Join-Path $PSScriptRoot "last_admin_build_output.log"
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

# Serializes admin-gate runs the same way gate.ps1's mutex does for Flutter:
# observed a same-session collision where a manually-started background
# `npm run build` was still running when this hook fired for a Stop event,
# and Turbopack refuses a second concurrent build outright ("Another next
# build process is already running") rather than queueing it.
$mutex = New-Object System.Threading.Mutex($false, "PulseHubAdminBuildGate")
$gotLock = $false
try {
    $gotLock = $mutex.WaitOne($timeoutMs + 60000)
} catch [System.Threading.AbandonedMutexException] {
    $gotLock = $true
}

if (-not $gotLock) {
    $reason = "Another admin-web build/test gate run has been in progress for over 6 minutes. Wait for it to finish rather than starting a new one."
    @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
    exit 2
}

try {

    function Invoke-Step($label, $argsLine) {
        if (Test-Path $logFile) {
            Add-Content -Path $logFile -Value "`n=== $label ===" -Encoding utf8
        } else {
            Set-Content -Path $logFile -Value "=== $label ===" -Encoding utf8
        }

        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "cmd.exe"
        $psi.Arguments = "/c npm.cmd $argsLine >> `"$logFile`" 2>&1"
        $psi.UseShellExecute = $false
        $psi.WorkingDirectory = $adminRoot

        $proc = [System.Diagnostics.Process]::Start($psi)
        $finished = $proc.WaitForExit($script:timeoutMs)

        if (-not $finished) {
            try { $proc.Kill($true) } catch {}
            Add-Content -Path $logFile -Value "`n[admin-gate] '$label' timed out and was killed." -Encoding utf8
            return 124
        }

        return $proc.ExitCode
    }

    # npm install if node_modules is missing/incomplete (first run after scaffold,
    # or after a peer pulls new dependencies).
    if (-not (Test-Path (Join-Path $adminRoot "node_modules"))) {
        $installExit = Invoke-Step "npm install" "install"
        if ($installExit -ne 0) {
            $attempt += 1
            Save-Attempt $attempt
            if ($attempt -gt $ceiling) {
                Write-Output "Admin-web gate ceiling reached ($ceiling attempts) - allowing stop despite 'npm install' failing. Needs manual review. See .claude/last_admin_build_output.log"
                exit 0
            }
            $reason = "admin-web: npm install is failing (attempt $attempt of $ceiling). Full output in .claude/last_admin_build_output.log"
            @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
            exit 2
        }
    }

    $buildExit = Invoke-Step "npm run build" "run build"
    $testExit = 0
    if ($buildExit -eq 0) {
        $testExit = Invoke-Step "npm test" "test"
    }

    if ($buildExit -eq 0 -and $testExit -eq 0) {
        Save-Attempt 0
        exit 0
    }

    $attempt += 1
    Save-Attempt $attempt

    if ($attempt -gt $ceiling) {
        Write-Output "Admin-web gate ceiling reached ($ceiling attempts) - allowing stop despite red build/test. Needs manual review. See .claude/last_admin_build_output.log"
        exit 0
    }

    $failed = if ($buildExit -ne 0) { "npm run build" } else { "npm test" }
    $reason = "admin-web: $failed is failing (attempt $attempt of $ceiling). Keep fixing until build and tests pass - do not stop or report completion while this gate is red. Full output in .claude/last_admin_build_output.log"
    @{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
    exit 2
} finally {
    $mutex.ReleaseMutex()
}
