#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan Start VMID (misal 100): " START_VMID
read -p "Masukkan End VMID (misal 105): " END_VMID

echo ""
echo "Akan menghapus VMID dari $START_VMID sampai $END_VMID"
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Dibatalkan."
  exit 1
fi

# ------------ Proses Hapus ------------
for (( vmid=$START_VMID; vmid<=$END_VMID; vmid++ ))
do
    echo ">> Menghapus VMID $vmid ..."
    qm destroy $vmid --purge 2>/dev/null

    if [ $? -eq 0 ]; then
        echo "✅ VMID $vmid berhasil dihapus."
    else
        echo "⚠️ VMID $vmid tidak ditemukan atau gagal dihapus."
    fi
    echo ""
done
