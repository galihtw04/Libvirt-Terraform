# create snapshoot

- create snapshot
```
virsh snapshot-create-as --domain server2 --name snapshot1 --description "23 November 2023"
virsh snapshot-list server2
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/e498ac9b-c4e4-49df-bca6-aad25c88dcf7)

- revert/restore snaphot
  - delete partition
```
ssh 10.20.10.11
lsblk
fdisk /dev/vdb
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/a4285051-4e5e-4ea6-aece-3019874f504e)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/21c1cfcb-a1a5-44af-9653-e2dbbfb8ac43)

 - verify
```
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/bcbb9da7-e48f-4bcf-8f85-826bd0c5a14a)

 - resore snapshot
```
virsh snapshot-revert --domain server2 --snapshotname snapshot1
```

 - verify
```
ssh 10.20.10.11
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/e77f55a8-be74-4a14-87c4-20671cec37dc)

# Remove snapshot

check snapshot
```
virsh snapshot-list server2
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/5e6a4d6f-ea3b-4c09-8b46-74c1b65e857a)

remove snapshot1
```
virsh snapshot-delete server2 --snapshotname snapshot1
virsh snapshot-list server2
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/2a5552f4-3b10-4f79-a87d-a4fa290570d8)
