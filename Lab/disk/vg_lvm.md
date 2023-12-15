# create vg
check partition yang akan digunakan untuk target VG
```
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/8d5d3e6c-35b3-4681-90bd-d4dcbb6d8d25)

create PV
```
pvcreate /dev/vdb1
pvs
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/7746d020-d9a4-4da1-94f1-67e64d17f294)

create VG
```
vgcreate nfs-share /dev/vdb1
vgs
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/e434c9f0-08f6-429b-ac50-5b11b3172876)

create Lv
```
lvcreate -l 100%FREE -n lvshare nfs-share
lvs
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/47ad2b87-95ac-4392-8adb-230ce7b7f583)

check
```
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/ddeb5c59-1c03-428a-b0e4-79e8e9a6800b)

format lvm and mount
```
mkfs.ext4  /dev/nfs-share/lvshare
mkdir /nfs-share
mount /dev/mapper/nfs--share-lvshare /nfs-share/
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/c2ac8e1a-bae4-425d-b778-89200ae90cad)


mount permanent in fstab
check id
```
blkid /dev/mapper/nfs--share-lvshare 
/dev/mapper/nfs--share-lvshare: UUID="46fdbf87-db28-494b-87a9-92794ca40f98" BLOCK_SIZE="4096" TYPE="ext4"
```

edit fstab
```
nano /etc/fstab
```

```
# lvm nfs--share-lvshare
UUID=46fdbf87-db28-494b-87a9-92794ca40f98       /nfs-share      ext4   defaults   0   0
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/b0af7a20-34ba-4941-a2ee-792d05368ac9)

apply fstab
```
mount -a
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/8491d8ee-e1a3-463a-b755-60ad98558a53)

# remove VG and lvm

remove or comment mounting in /etc/fstab
```
nano /etc/fstab
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/66079922-5cb9-416a-b639-4dd70623a68a)

umount /nfs-share
```
umount /nfs-share/
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/523f6863-735d-478e-acc6-01f542efd6f7)

remove lvm
```
lvchange -an /dev/nfs-share/lvshare
lvremove /dev/nfs-share/lvshare 
Do you really want to remove and DISCARD logical volume nfs-share/lvshare? [y/n]: y
lvs
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/b64d97db-3ee3-4452-a42b-1083bf82f71f)

checking
```
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/2014dac8-f65b-481d-9cb4-685ec247b345)

remove vg
```
vgs
vgremove nfs-share
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/5ef77230-7710-43a8-8f14-d27700c8ccfd)

remove PV
```
pvs
pvremove /dev/vdb1
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/6a4c04bd-468d-4a8c-9b13-4cd4c6ca8edd)

remove partition
```
fdisk /dev/vdb
Welcome to fdisk (util-linux 2.37.2).
Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.


Command (m for help): d
Selected partition 1
Partition 1 has been deleted.

Command (m for help): w
The partition table has been altered.
Calling ioctl() to re-read partition table.
Syncing disks.

root@k8s-student-master01:~# 
```

checking
```
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/88a0f0ea-e32c-4080-84a9-952d245fcef1)
