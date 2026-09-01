$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$flutterExe = "C:\flutter\bin\flutter.bat"
if (-not (Test-Path $flutterExe)) { $flutterExe = "flutter" }

$stateFile = Join-Path $PSScriptRoot "gate_state.json"
$logFile = Join-Path $PSScriptRoot "last_test_output.log"
$ceiling = 20

$attempt = 0
if (Test-Path $stateFile) {
    try {
        $state = Get-Content $stateFile -Raw | ConvertFrom-Json
        $attempt = [int]$state.attempt
    } catch {
        $attempt = 0
    }
}

$testOutput = & $flutterExe test 2>&1 | Out-String
$testExit = $LASTEXITCODE
Set-Content -Path $logFile -Value $testOutput -Encoding utf8

if ($testExit -eq 0) {
    Set-Content -Path $stateFile -Value '{"attempt": 0}' -Encoding utf8
    exit 0
}

$attempt += 1
Set-Content -Path $stateFile -Value (@{ attempt = $attempt } | ConvertTo-Json -Compress) -Encoding utf8

if ($attempt -gt $ceiling) {
    $msg = "Gate ceiling reached ($ceiling failed attempts in a row) - allowing stop despite red 'flutter test'. This needs manual review. See .claude/last_test_output.log for the last failure."
    Write-Output $msg
    exit 0
}

$reason = "flutter test is failing (attempt $attempt of $ceiling). Keep fixing until all tests pass - do not stop or report completion while this gate is red. Full output in .claude/last_test_output.log"
@{ decision = "block"; reason = $reason } | ConvertTo-Json -Compress | Write-Output
exit 2
