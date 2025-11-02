#!/bin/bash

# proxmox-delete-vm.sh
# Enhanced: terima input daftar VMID dan range (contoh: 101-105,201-205,309,310)
# - Expand ranges dan single VMID
# - Dedupe dan sort
# - Tampilkan ringkasan dan minta konfirmasi
# - Opsi dry-run (hanya tampilkan perintah tanpa menjalankan)

set -o pipefail

echo "Masukkan VMID atau rentang VMID (contoh: 101-105,201-205,309,310)"
read -p ">> Input: " INPUT
read -p "Lakukan dry-run (hanya tampilkan perintah, tanpa menghapus)? (yes/no): " DRYRUN

vmids=()

# Split berdasarkan koma dan proses tiap entri
IFS=',' read -ra parts <<< "$INPUT"
for part in "${parts[@]}"; do
    # Hapus whitespace
    part="${part//[[:space:]]/}"
    [[ -z "$part" ]] && continue

    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        start=${BASH_REMATCH[1]}
        end=${BASH_REMATCH[2]}
        if (( start > end )); then
            echo "⚠️ Range $part tidak valid (start > end). Menukar nilai."
            tmp=$start; start=$end; end=$tmp
        fi
        for ((i=start;i<=end;i++)); do
            vmids+=("$i")
        done
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
        vmids+=("$part")
    else
        echo "⚠️ Mengabaikan entri tidak valid: $part" >&2
    fi
done

if [ ${#vmids[@]} -eq 0 ]; then
    echo "Tidak ada VMID valid yang ditemukan. Keluar."
    exit 1
fi

# Dedupe dan sort numerik
mapfile -t unique_vmids < <(printf "%s\n" "${vmids[@]}" | sort -n -u)

echo ""
echo "Akan menghapus VMID berikut (total: ${#unique_vmids[@]}):"
printf "%s\n" "${unique_vmids[@]}"
echo ""
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
    echo "Dibatalkan."
    exit 1
fi

if ! command -v qm >/dev/null 2>&1; then
    echo "Perintah 'qm' tidak ditemukan. Pastikan script dijalankan di host Proxmox." >&2
    exit 1
fi

for vmid in "${unique_vmids[@]}"; do
    echo ">> Menghapus VMID $vmid ..."
    if [[ "$DRYRUN" == "yes" ]]; then
        echo "DRY-RUN: qm destroy $vmid --purge"
        echo ""
        continue
    fi

    if qm destroy "$vmid" --purge 2>/dev/null; then
        echo "✅ VMID $vmid berhasil dihapus."
    else
        echo "⚠️ VMID $vmid tidak ditemukan atau gagal dihapus."
    fi
    echo ""
done
