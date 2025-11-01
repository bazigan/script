#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan Start VMID (misal 100): " START_VMID
read -p "Masukkan End VMID (misal 105): " END_VMID

echo ""
echo "Akan memasukkan VMID $START_VMID sampai $END_VMID ke pool masing-masing pesertaX (berdasarkan angka belakang VMID)"
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Dibatalkan."
  exit 1
fi

# ------------ Proses Assign ke Pool ------------
for (( vmid=$START_VMID; vmid<=$END_VMID; vmid++ )); do
    # Ambil angka terakhir dari VMID
    NUMBER=$(( vmid % 100 ))   # misal 101 → 1, 112 → 12
    POOL_NAME="peserta$NUMBER"

    echo ">> Memasukkan VMID $vmid ke pool $POOL_NAME ..."

    # Cek apakah pool ada
    if ! pveum pool list | awk '{print $2}' | grep -qx "$POOL_NAME"; then
        echo "⚠️ Pool $POOL_NAME tidak ada, lewati VMID $vmid."
        continue
    fi

    # Tambahkan VM ke pool
    if pveum pool modify "$POOL_NAME" --vms $vmid; then
        echo "✅ VMID $vmid berhasil dimasukkan ke pool $POOL_NAME."
    else
        echo "⚠️ Gagal memasukkan VMID $vmid ke pool $POOL_NAME."
    fi
    echo ""
done

