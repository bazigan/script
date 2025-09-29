vswitch_name="Proxmox-Internal"

i=1
while [ $i -le 10 ]
do
  portgroup_name="Peserta-$i"
  vlan_id=$(($i * 10))
  esxcli network vswitch standard portgroup add --portgroup-name="$portgroup_name" --vswitch-name="$vswitch_name"
  esxcli network vswitch standard portgroup set --portgroup-name="$portgroup_name" --vlan-id="$vlan_id"
  echo "Portgroup $portgroup_name created on vSwitch $vswitch_name with VLAN ID $vlan_id"
  i=$((i + 1))
done