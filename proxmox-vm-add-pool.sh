#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan Start VMID (misal 100): " START_VMID
read -p "Masukkan End VMID (misal 105): " END_VMID
read -p "Masukkan Prefix Nama Pool (misal: redhat): " POOL_PREFIX
read -p "Masukkan Angka Awal Pool (misal: 1 untuk redhat1): " START_POOL_NUM

echo ""
echo "Akan memasukkan VMID $START_VMID - $END_VMID secara berurutan"
echo "ke pool $POOL_PREFIX$START_POOL_NUM dan seterusnya..."
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Dibatalkan."
  exit 1
fi

# ------------ Proses Assign ke Pool ------------
# Set nilai awal untuk nomor pool
POOL_NUM=$START_POOL_NUM

for (( vmid=$START_VMID; vmid<=$END_VMID; vmid++ )); do
    # Gabungkan prefix dan nomor urut menjadi nama pool
    POOL_NAME="${POOL_PREFIX}${POOL_NUM}"

    echo ">> Memasukkan VMID $vmid ke pool $POOL_NAME ..."

    # Cek apakah pool ada
    if ! pveum pool list | awk '{print $2}' | grep -qx "$POOL_NAME"; then
        echo "⚠️ Pool $POOL_NAME tidak ada, lewati VMID $vmid."
    else
        # Tambahkan VM ke pool
        if pveum pool modify "$POOL_NAME" --vms $vmid; then
            echo "✅ VMID $vmid berhasil dimasukkan ke pool $POOL_NAME."
        else
            echo "⚠️ Gagal memasukkan VMID $vmid ke pool $POOL_NAME."
        fi
    fi
    echo ""
    
    # Naikkan angka pool untuk VMID berikutnya (misal dari 1 jadi 2)
    ((POOL_NUM++))
done