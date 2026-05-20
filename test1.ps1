$password = "TP2026"

$folder = "$HOME\Desktop\tp-simulation"

# --- CREATION CLE AES ---

$sha = New-Object System.Security.Cryptography.SHA256Managed
$key = $sha.ComputeHash(
    [System.Text.Encoding]::UTF8.GetBytes($password)
)

# --- CHIFFREMENT DE TOUS LES TXT ---

$files = Get-ChildItem $folder -File -Filter "*.txt"

foreach ($file in $files)
{
    $data = [System.IO.File]::ReadAllBytes($file.FullName)

    $aes = New-Object System.Security.Cryptography.AesManaged
    $aes.Key = $key
    $aes.GenerateIV()

    $encryptor = $aes.CreateEncryptor()

    $encryptedData = $encryptor.TransformFinalBlock(
        $data,
        0,
        $data.Length
    )

    $result = $aes.IV + $encryptedData

    $outputFile = $file.FullName + ".enc"

    [System.IO.File]::WriteAllBytes($outputFile, $result)

    Write-Host "Chiffre :" $file.Name
}

Write-Host ""
Write-Host "Tous les fichiers sont chiffres."
Write-Host ""

# --- DEMANDE MOT DE PASSE ---

$userPassword = Read-Host "Entrer le mot de passe"

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

    $decryptedData = $decryptor.TransformFinalBlock(
        $encryptedData,
        0,
        $encryptedData.Length
    )

    $originalName = $encFile.FullName.Replace(".enc", "")

    $outputFile = $originalName.Replace(".txt", "_dechiffre.txt")

    [System.IO.File]::WriteAllBytes($outputFile, $decryptedData)

    Write-Host "Dechiffre :" $encFile.Name
}

Write-Host ""
Write-Host "Tous les fichiers ont ete dechiffres."