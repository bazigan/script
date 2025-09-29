#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan Start Nomor Peserta (misal 1): " START_NUM
read -p "Masukkan End Nomor Peserta (misal 10): " END_NUM
read -p "Masukkan Role yang ingin dihapus (misal PVEVMAdmin): " ROLE

echo ""
echo "Akan menghapus permission role '$ROLE' dari pool pesertaX untuk user pesertaX@pve (X=$START_NUM..$END_NUM)"
read -p "Yakin ingin melanjutkan? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Dibatalkan."
  exit 1
fi

# ------------ Proses Hapus Permission ------------
for (( num=$START_NUM; num<=$END_NUM; num++ )); do
    POOL_NAME="peserta$num"
    USER_NAME="peserta${num}@pve"

    echo ">> Menghapus role $ROLE untuk $USER_NAME di pool $POOL_NAME ..."
    if pveum acl delete /pool/$POOL_NAME --roles $ROLE --users $USER_NAME; then
        echo "✅ Permission dihapus untuk $USER_NAME pada pool $POOL_NAME."
    else
        echo "⚠️ Gagal menghapus permission $USER_NAME pada pool $POOL_NAME."
    fi
    echo ""
done

