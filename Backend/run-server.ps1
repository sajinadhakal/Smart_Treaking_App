Set-Location 'C:\Users\sazna\6th_sem\Backend'
$Host.UI.RawUI.WindowTitle = 'Backend Server - Nepal Trekking App'

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
Write-Host ''
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ' Backend Server Running' -ForegroundColor Green
Write-Host '=================================' -ForegroundColor Cyan
Write-Host "Server URL: http://${lanIp}:8000" -ForegroundColor Green
Write-Host "Admin Panel: http://${lanIp}:8000/admin" -ForegroundColor Green
Write-Host "API Root: http://${lanIp}:8000/api/" -ForegroundColor Green
Write-Host ''
Write-Host 'Press Ctrl+C to stop the server' -ForegroundColor Yellow
Write-Host '=================================' -ForegroundColor Cyan
Write-Host ''
& 'C:\Users\sazna\6th_sem\Backend\venv\Scripts\python.exe' manage.py runserver 0.0.0.0:8000
