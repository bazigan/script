#!/bin/bash

# ------------ Input dari User ------------
read -p "Masukkan Template ID (misal 1000): " TEMPLATE_ID
read -p "Masukkan Start VMID (misal 100): " START_VMID
read -p "Masukkan End VMID (misal 105): " END_VMID
read -p "Masukkan format nama VM (gunakan {} untuk angka, contoh: SERVER1-PESERTA-{}): " NAME_FORMAT
read -p "Apakah ingin menambahkan ke resource pool per peserta (y/n)? " ADD_POOL

echo ""
echo "Akan melakukan clone dari template $TEMPLATE_ID ke VMID $START_VMID s/d $END_VMID"
echo "Format nama: $NAME_FORMAT"
echo ""

# ------------ Proses Clone ------------
for (( vmid=$START_VMID; vmid<=$END_VMID; vmid++ )); do
    NUMBER=$(( vmid - START_VMID + 1 ))
    VM_NAME=${NAME_FORMAT//\{\}/$NUMBER}

    if [[ "$ADD_POOL" =~ ^[Yy]$ ]]; then
        POOL_NAME="peserta$NUMBER"
        echo ">> Cloning ke VMID $vmid dengan nama $VM_NAME ke pool $POOL_NAME ..."
        qm clone $TEMPLATE_ID $vmid --full --name "$VM_NAME" --pool "$POOL_NAME"
    else
        echo ">> Cloning ke VMID $vmid dengan nama $VM_NAME ..."
        qm clone $TEMPLATE_ID $vmid --full --name "$VM_NAME"
    fi

    if [ $? -eq 0 ]; then
        echo "✅ Clone VMID $vmid sukses."
    else
        echo "❌ Clone VMID $vmid gagal."
    fi
    echo ""
done

