Set-Location $PSScriptRoot
$Host.UI.RawUI.WindowTitle = 'Flutter App - Nepal Trekking App'

function Get-LanIp {
    if (Get-Command Get-NetIPAddress -ErrorAction SilentlyContinue) {
        $ip = Get-NetIPAddress -AddressFamily IPv4 |
            Where-Object { $_.IPAddress -notmatch '^(127|169)\.' } |
            Select-Object -First 1 -ExpandProperty IPAddress
        if ($ip) {
            return $ip
        }
    }

    $ip = ipconfig |
        Select-String -Pattern '\d{1,3}(?:\.\d{1,3}){3}' |
        ForEach-Object { $_.Matches } |
        ForEach-Object { $_.Value } |
        Where-Object { $_ -notmatch '^(127|169)\.' } |
        Select-Object -First 1

    if ($ip) {
        return $ip
    }

    return '127.0.0.1'
}

$lanIp = Get-LanIp
$apiBaseUrl = if ([string]::IsNullOrWhiteSpace($env:API_BASE_URL)) { "http://${lanIp}:8000/api" } else { $env:API_BASE_URL }

Write-Host ''
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ' Flutter App Running' -ForegroundColor Green
Write-Host '=================================' -ForegroundColor Cyan
Write-Host "API_BASE_URL = $apiBaseUrl" -ForegroundColor Green
Write-Host ''
flutter run --dart-define "API_BASE_URL=$apiBaseUrl"
