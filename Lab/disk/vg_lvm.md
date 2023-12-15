# create vg
check partition yang akan digunakan untuk target VG
```
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/61346637-d593-49ff-a3eb-3b0d3c8e0b52)

create PV
```
pvcreate /dev/vdb1
pvs
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/29ebcca6-2389-4d81-bd53-866ae9566401)

create VG
```
vgcreate nfs-share /dev/vdb1
vgs
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/d0fb5421-f131-4f5f-84d3-91c795089bdb)

create Lv
```
lvcreate -l 100%FREE -n lvshare nfs-share
lvs
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/2f100286-b230-4c9a-a327-a226091d96af)

check
```
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/ec3ba3e2-bd23-444b-be7c-573daf631040)

format lvm and mount
```
mkfs.ext4  /dev/nfs-share/lvshare
mkdir /nfs-share
mount /dev/mapper/nfs--share-lvshare /nfs-share/
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/65a55de7-5474-4a7d-b495-922914768eb7)

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
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/d2c63c03-a145-4c0b-adc0-1190c8ca82a2)

apply fstab
```
mount -a
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/0a7a9f20-1c95-423f-b7c1-e27d4b56dfb4)

# remove VG and lvm

remove or comment mounting in /etc/fstab
```
nano /etc/fstab
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/010f64f4-07ba-4195-823f-e5725aab976c)

umount /nfs-share
```
umount /nfs-share/
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/ee307538-07df-4f97-ac25-54726bc10cca)

remove lvm
```
lvchange -an /dev/nfs-share/lvshare
lvremove /dev/nfs-share/lvshare 
Do you really want to remove and DISCARD logical volume nfs-share/lvshare? [y/n]: y
lvs
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/8fe8c61a-ccbb-46d3-bf51-55263432606e)

checking
```
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/0483aa35-37ea-4d8b-bfb1-75ebccfe9c40)

remove vg
```
vgs
vgremove nfs-share
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/e533873e-ce00-4ddf-9138-0cafefb60269)

remove PV
```
pvs
pvremove /dev/vdb1
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/9a33ff67-8d1c-40f8-a9a6-ef44c68fdfed)

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
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/dfa62f2e-ed0b-4ea7-a9d7-3eac10cdfd7a)
