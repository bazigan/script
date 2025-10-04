# login-vcenter.ps1

# Input koneksi ke vCenter
function Read-Host-Default {
    param (
        [string]$Prompt,
        [string]$Default
    )
    $input = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($input)) {
        return $Default
    } else {
        return $input
    }
}

$defaultVcenter = "172.23.0.20"
$defaultUser = "administrator@idn.local"

$vcenterServer = Read-Host-Default "🔐 Masukkan hostname atau IP vCenter" $defaultVcenter
$vcenterUser = Read-Host-Default "👤 Masukkan username vCenter" $defaultUser
$vcenterPass = Read-Host "🔑 Masukkan password vCenter" -AsSecureString

# Abaikan SSL cert warning
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false | Out-Null

# Buat credential object
$creds = New-Object System.Management.Automation.PSCredential($vcenterUser, $vcenterPass)

# Connect ke vCenter
Connect-VIServer -Server $vcenterServer -Credential $creds

Write-Host "✅ Berhasil login ke $vcenterServer"
Write-Host "💡 Simpan session PowerCLI ini, jalankan script cloning di session yang sama."