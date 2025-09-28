# clone-vm.ps1

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

$defaultDatacenter = "DC IDN-PALMERAH"
$defaultNetwork = "VM Network"

# Input untuk cloning VM
$templateName = Read-Host "📦 Masukkan nama Template (hasil Convert to Template)"
$prefixInput = Read-Host "🖥️ Masukkan daftar prefix VM, pisah dengan koma (contoh: PVE1,PVE2,PVE3)"
$prefixList = $prefixInput.Split(",") | ForEach-Object { $_.Trim() }
$vmCountPerPrefix = Read-Host "🔢 Berapa banyak VM per prefix yang ingin dibuat?" | ForEach-Object { [int]$_ }

$datacenterName = Read-Host-Default "🏢 Masukkan nama Datacenter" $defaultDatacenter
$vmHostName = Read-Host "🖥️ Masukkan nama VMHost (ESXi Host) tempat VM akan dideploy (contoh: 192.168.20.108)"
$datastoreName = Read-Host-Default "💾 Masukkan nama Datastore" ""
$networkName = Read-Host-Default "🌐 Masukkan nama Network / PortGroup" $defaultNetwork
$vmFolder = Read-Host "📁 Masukkan nama Folder VM (tekan Enter untuk default)"

# Ambil objek vSphere (asumsi sudah login di session yang sama)
$template = Get-Template -Name $templateName -ErrorAction Stop
$datacenter = Get-Datacenter -Name $datacenterName
$vmHost = Get-VMHost -Name $vmHostName -Location $datacenter -ErrorAction Stop

if ([string]::IsNullOrWhiteSpace($datastoreName)) {
    # Ambil datastore default dari host (yang free space terbesar)
    $datastore = $vmHost | Get-Datastore | Sort-Object FreeSpaceGB -Descending | Select-Object -First 1
    Write-Host "💾 Datastore tidak diisi, otomatis pakai $($datastore.Name)"
} else {
    $datastore = Get-Datastore -Name $datastoreName -Location $datacenter
}

$network = Get-VirtualPortGroup -Name $networkName
$folder = if ($vmFolder) { Get-Folder -Name $vmFolder -Location $datacenter } else { Get-Folder -Name "vm" -Location $datacenter }

Write-Host "DEBUG: VMHost yang digunakan:" $vmHost.Name

Write-Host "🚀 Mulai proses cloning VM..."

foreach ($prefix in $prefixList) {
    Write-Host "🔄 Membuat $vmCountPerPrefix VM dengan prefix $prefix..."

    1..$vmCountPerPrefix | ForEach-Object {
        $number = "{0:D2}" -f $_
        $newVMName = "$prefix-$number"

        Write-Host "🚀 Membuat VM: $newVMName ..."

        New-VM -Name $newVMName `
               -Template $template `
               -Datastore $datastore `
               -VMHost $vmHost `
               -Location $folder `
               -NetworkName $network.Name `
               -Confirm:$false | Out-Null

        Write-Host "✅ $newVMName berhasil dibuat."
    }
}

Write-Host "🎉 Semua VM selesai di-clone."
