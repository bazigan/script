#!/bin/bash
# Script: add-disk-vm.sh
# Fungsi: Menambahkan disk ke beberapa VM Proxmox secara batch

echo "=== Tambah Disk ke Beberapa VM Proxmox ==="
read -p "Masukkan VMID awal        : " START_ID
read -p "Masukkan VMID akhir       : " END_ID
read -p "Masukkan nama storage     : " STORAGE
read -p "Masukkan ukuran disk (GB) : " SIZE
read -p "Masukkan format (misal raw/qcow2) : " FORMAT
read -p "Masukkan nomor SCSI (misal 1 jika scsi0 sudah terpakai) : " SCSI_NUM

echo ""
echo "Konfirmasi:"
echo "  VMID: $START_ID sampai $END_ID"
echo "  Storage: $STORAGE"
echo "  Ukuran: ${SIZE}G"
echo "  Format: $FORMAT"
echo "  SCSI slot: scsi${SCSI_NUM}"
echo ""
read -p "Lanjutkan proses? (y/n): " CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Dibatalkan."
  exit 1
fi

for (( VMID=$START_ID; VMID<=$END_ID; VMID++ ))
do
  echo "Menambahkan disk ke VMID $VMID ..."
  qm set $VMID --scsi${SCSI_NUM} ${STORAGE}:${SIZE},format=${FORMAT}
  if [[ $? -eq 0 ]]; then
    echo "  ✅ Berhasil menambahkan disk ke VM $VMID"
  else
    echo "  ❌ Gagal menambahkan disk ke VM $VMID"
  fi
done

echo ""
echo "Selesai menambahkan disk ke VM ${START_ID}–${END_ID}."
