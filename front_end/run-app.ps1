Set-Location 'C:\Users\sazna\6th_sem\front_end'
$Host.UI.RawUI.WindowTitle = 'Flutter App - Nepal Trekking App'

function Get-LanIp {
	$ipLine = ipconfig |
		Select-String -Pattern 'IPv4[^:]*:\s*(\d+\.\d+\.\d+\.\d+)' |
		Select-Object -First 1

	if ($ipLine -and $ipLine.Matches.Count -gt 0) {
		return $ipLine.Matches[0].Groups[1].Value
	}

	return '127.0.0.1'
}

$lanIp = Get-LanIp
$apiBaseUrl = $env:API_BASE_URL

if ([string]::IsNullOrWhiteSpace($apiBaseUrl)) {
	$apiBaseUrl = "http://${lanIp}:8000/api"
}

Write-Host ''
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ' Flutter App Running' -ForegroundColor Green
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ''
Write-Host "Connected backend: $apiBaseUrl" -ForegroundColor Green
Write-Host "Detected LAN IP: $lanIp" -ForegroundColor Green
Write-Host ''
flutter run --dart-define "API_BASE_URL=$apiBaseUrl"
