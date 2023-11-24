# expand disk
- before disk server1
  - vda1 / = 50G

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/8aa0991b-bb88-4f42-9148-13c1d40e8eed)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/5029314b-7233-4d60-9050-af59333cb264)


- expand disk
  - vda1 50G expand to 100G
  - make sure vm shutdown, because are will expand disk root
```
virsh list --all
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/d62fcb52-8562-4e6e-b6a1-55ee9105daed)

  - example command expand
```
virsh vol-resize --pool <name pool> --vol <nama disk vm> --capacity <resize to>
```
  - command expand
```
virsh vol-resize --pool data-disk --vol server1-vda.qcow2 --capacity 100G
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/42cd6253-71fd-4a37-b5a7-c181aac54147)


start vm
```
virsh start server1
virsh list --all
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/897edda3-94de-4667-a8bc-21a2622b96d3)


- verify
```
ssh 10.20.10.10
df -h
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/d34f00f2-633d-43df-ad8e-66431cf60d97)


# remove disk vdb from server1

- check disk vdb
```
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/132b3d23-e74d-42f0-83d0-7394ed7fd0c4)

- take out disk vdb
```
virsh list --all
virsh detach-disk server1 --target vdb --live
```

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/2a346fdd-fe59-44a3-9866-8ad13d0da87a)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/cc0cd775-47dd-49d8-964a-42b65255448b)

- verify
```
ssh 10.20.10.10
lsblk
```

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/b559cb69-8416-4eba-a8de-e3afa289326b)


- take in vdb
```
virsh attach-disk server1 --source /data-disk/server1-vdb.qcow2 --target vdb --live
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/abd0e35d-5b7e-482c-a530-b2946cdc7494)


- verify
```
ssh 10.20.10.10
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/c87d5dd4-a124-48c6-b23c-3e050bbde33b)


> # note
> jika pada linux server terbacanya adalah size allocation dari disk (cara check allocation dan cappacity *virsh vol-list --pool data-disk --details* ), bisa kalian resize disk tersebut menjadi 20G


# create new disk
- create disk
```
qemu-img create -f qcow2 -o preallocation=metadata /data-disk/server2-vdb.qcow2 10G
virsh vol-list --pool data-disk --details
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/d7a883d1-1d01-4d3a-bb82-971484535d9f)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/1e7dce80-628e-42ed-8400-b9d6e23a21ef)


- refresh pool
```
virsh pool-refresh --pool data-disk
virsh vol-list --pool data-disk --details
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/82ebb793-2c66-4990-b322-560239e03e54)

- attach disk server2-vdb.qcow2 on server2
```
virsh list --all
virsh attach-disk server2 --source /data-disk/server2-vdb.qcow2 --target vdb --type disk --subdriver qcow2 --live
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/dee7a7c5-affb-40ff-9bd3-4a072aa9df5c)


- verify
```
ssh 10.20.10.11
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/6cbc7b84-59b4-422b-b606-33987925c081)

# create partition

create partition
```
fdisk /dev/vdb
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/49a4966a-face-4830-b965-77d7fb83239a)

- format partition
```
mkfs.ext4 /dev/vdb1
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/a3b26001-2355-4358-acda-a8452cab24b7)


- verify and mount
```
mkdir /disk-extend
mount /dev/vdb1 /disk/extend
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/493752fe-0427-40de-86de-4eb04a9fbac4)
