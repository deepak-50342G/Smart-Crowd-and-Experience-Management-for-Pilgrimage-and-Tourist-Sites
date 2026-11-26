$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$nodeCommand = Get-Command node -ErrorAction Stop
$flutterCommand = Get-Command flutter -ErrorAction Stop
$proxyProcess = Start-Process `
    -FilePath $nodeCommand.Source `
    -ArgumentList @('.\backend\server.js') `
    -WorkingDirectory $projectRoot `
    -NoNewWindow `
    -PassThru

try {
    $proxyReady = $false
    $lastHealthError = 'No health response received.'
    $deadline = (Get-Date).AddSeconds(15)

    while ((Get-Date) -lt $deadline) {
        if ($proxyProcess.HasExited) {
            throw "Gemini proxy exited with code $($proxyProcess.ExitCode). Check GEMINI_API_KEY."
        }

        try {
            $health = Invoke-RestMethod `
                -Uri 'http://127.0.0.1:3000/health' `
                -TimeoutSec 1
            if ($health.ok -eq $true) {
                $proxyReady = $true
                break
            }
            $lastHealthError = 'The proxy returned an unexpected health response.'
        }
        catch {
            $lastHealthError = $_.Exception.Message
        }

        Start-Sleep -Milliseconds 300
    }

    if (-not $proxyReady) {
        throw "Gemini proxy did not become ready: $lastHealthError"
    }

    Set-Location $projectRoot
    & $flutterCommand.Source run -d chrome
    if ($LASTEXITCODE -ne 0) {
        throw "flutter run exited with code $LASTEXITCODE."
    }
}
finally {
    if (-not $proxyProcess.HasExited) {
        Stop-Process -Id $proxyProcess.Id
    }
}
