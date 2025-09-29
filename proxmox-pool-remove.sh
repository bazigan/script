#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan nama pool (misal training): " POOL_NAME
read -p "Masukkan Start VMID (misal 100): " START_VMID
read -p "Masukkan End VMID (misal 105): " END_VMID

echo ""
echo "Akan menghapus VMID $START_VMID sampai $END_VMID dari pool '$POOL_NAME'"
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Dibatalkan."
  exit 1
fi

# ------------ Proses Remove dari Pool ------------
for (( vmid=$START_VMID; vmid<=$END_VMID; vmid++ ))
do
    echo ">> Menghapus VMID $vmid dari pool $POOL_NAME ..."
    pveum pool modify "$POOL_NAME" --vms $vmid --delete

    if [ $? -eq 0 ]; then
        echo "✅ VMID $vmid berhasil dihapus dari pool $POOL_NAME."
    else
        echo "⚠️ Gagal menghapus VMID $vmid dari pool $POOL_NAME (mungkin tidak ada di pool)."
    fi
    echo ""
done
