DATASTORE="DS-LOCAL-02"
SRC_VM="template-proxmox"
PREFIX="pve"
START=1
END=15
DISK_TYPE="thin"

SRC_PATH="/vmfs/volumes/$DATASTORE/$SRC_VM"

if [ ! -d "$SRC_PATH" ]; then
  echo "ERROR: Source VM not found"
  exit 1
fi

i=$START
while [ $i -le $END ]; do
  NUM=$(printf "%02d" $i)
  CLONE_VM="$PREFIX-$NUM"
  DST_PATH="/vmfs/volumes/$DATASTORE/$CLONE_VM"

  echo "Cloning $CLONE_VM"

  mkdir -p "$DST_PATH" || exit 1

  vmkfstools -i \
    "$SRC_PATH/$SRC_VM.vmdk" \
    "$DST_PATH/$CLONE_VM.vmdk" \
    -d $DISK_TYPE || exit 1

  cp "$SRC_PATH/$SRC_VM.vmx" "$DST_PATH/$CLONE_VM.vmx"

  if [ -f "$SRC_PATH/$SRC_VM.nvram" ]; then
    cp "$SRC_PATH/$SRC_VM.nvram" "$DST_PATH/$CLONE_VM.nvram"
  fi

  sed -i "s/displayName = \".*\"/displayName = \"$CLONE_VM\"/" \
    "$DST_PATH/$CLONE_VM.vmx"

  sed -i "s/$SRC_VM.vmdk/$CLONE_VM.vmdk/" \
    "$DST_PATH/$CLONE_VM.vmx"

  sed -i '/uuid.bios/d' "$DST_PATH/$CLONE_VM.vmx"
  sed -i '/ethernet.*address/d' "$DST_PATH/$CLONE_VM.vmx"

  vim-cmd solo/registervm "$DST_PATH/$CLONE_VM.vmx"

  i=$((i + 1))
done

echo "DONE"
