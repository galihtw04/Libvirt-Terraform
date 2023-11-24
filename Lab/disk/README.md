# expand disk
- before disk server1
  - vda1 / = 50G

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/06720620-98f1-4dfb-85a9-af14629a34a6)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/ab4fe078-c956-42ed-a408-ba1a7bbaacc9)

- expand disk
  - vda1 50G expand to 100G
  - make sure vm shutdown, because are will expand disk root
```
virsh list --all
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/d7a2cbf2-1273-4118-ad27-353cb70bd07f)

expand
```
virsh vol-resize --pool <name pool> --vol <nama disk vm> --capacity <resize to>
```

```
virsh vol-resize --pool data-disk --vol server1-vda.qcow2 --capacity 100G
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/697ff54d-ac6f-448a-86f8-e06b5373be9e)

start vm
```
virsh start server1
virsh list --all
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/a8d328c2-6361-4b47-b1b3-2b8f605e9bb7)

- verify
```
ssh 10.20.10.10
df -h
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/dba9372f-0027-492c-b3f3-381bab2eb20a)

# remove disk vdb from server1

- check disk vdb
```
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/ecfaa3a4-88b4-48a0-a0cc-148974974ca9)

- take out disk vdb
```
virsh list --all
virsh detach-disk server1 --target vdb --live
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/a62907aa-6129-4686-af9a-3ceaf002a7a6)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/042df1bf-37eb-4544-87cf-f23aced645ab)

- verify
```
ssh 10.20.10.10
lsblk
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/4495f195-e185-4914-a2b1-5a93f35cca1c)

- take in vdb
```
virsh attach-disk server1 --source /data-disk/server1-vdb.qcow2 --target vdb --live
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/ae82999c-0b38-4e2e-891e-f3e4996b4dee)

- verify
```
ssh 10.20.10.10
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/bc42ffe1-c2b7-4f41-851c-8e186217761d)

> # note
> jika pada linux server terbacanya adalah size allocation dari disk (cara check allocation dan cappacity *virsh vol-list --pool data-disk --details* ), bisa kalian resize disk tersebut menjadi 20G


# create new disk
- create disk
```
qemu-img create -f qcow2 -o preallocation=metadata /data-disk/server2-vdb.qcow2 10G
virsh vol-list --pool data-disk --details
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/f0d6a04b-4449-421b-a0d6-9305dfb6a127)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/13d8480a-4a4d-47fe-a8ed-01efc0e39fa1)

- refresh pool
```
virsh pool-refresh --pool data-disk
virsh vol-list --pool data-disk --details
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/4883a301-667d-4e86-a7d3-59a57fdea454)

- attach disk server2-vdb.qcow2 on server2
```
virsh list --all
virsh attach-disk server2 --source /data-disk/server2-vdb.qcow2 --target vdb --type disk --subdriver qcow2 --live
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/46065595-99f6-4e52-80ab-c05d38a365a6)

- verify
```
ssh 10.20.10.11
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/e288638e-2872-43e5-8198-af7b230bae33)

# create partition

create partition
```
fdisk /dev/vdb
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/85649355-9168-4371-b916-09e4809de582)

- format partition
```
mkfs.ext4 /dev/vdb1
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/d572ef16-2ab2-45ad-929e-c740862c6a00)

- verify and mount
```
mkdir /disk-extend
mount /dev/vdb1 /disk/extend
lsblk
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/92be4e93-e377-4aed-9d8e-7b8263bcfdcb)
