#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan nama pool (misal training): " POOL_NAME
read -p "Masukkan Start VMID (misal 100): " START_VMID
read -p "Masukkan End VMID (misal 105): " END_VMID

echo ""
echo "Akan menambahkan VMID $START_VMID sampai $END_VMID ke pool '$POOL_NAME'"
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Dibatalkan."
  exit 1
fi

# ------------ Proses Remove dari Pool ------------
for (( vmid=$START_VMID; vmid<=$END_VMID; vmid++ ))
do
    echo ">> Menambahkan VMID $vmid ke pool $POOL_NAME ..."
    pveum pool modify "$POOL_NAME" --vms $vmid

    if [ $? -eq 0 ]; then
        echo "✅ VMID $vmid berhasil ditambahkan ke pool $POOL_NAME."
    else
        echo "⚠️ Gagal menambahkan VMID $vmid ke pool $POOL_NAME (mungkin sudah ada di pool)."
    fi
    echo ""
done
