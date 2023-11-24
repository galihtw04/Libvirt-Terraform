# create snapshoot

- create snapshot
```
virsh snapshot-create-as --domain server2 --name snapshot1 --description "23 November 2023"
virsh snapshot-list server2
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/cd556f94-e125-4cce-a556-992a46f00f7f)


- revert/restore snaphot
  - delete partition
```
ssh 10.20.10.11
lsblk
fdisk /dev/vdb
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/8c1cdbab-262a-4909-a472-93a7f3631ff6)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/4545defc-e87d-4dc5-9f1a-5426f68f1f27)

 - verify
```
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/446429b5-7452-44c7-b17f-c1a7996899e7)


 - resore snapshot
```
virsh snapshot-revert --domain server2 --snapshotname snapshot1
```

 - verify
```
ssh 10.20.10.11
lsblk
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/c76bfd7e-1544-46f2-aa45-2c6c538be4e2)

# Remove snapshot

- check snapshot
```
virsh snapshot-list server2
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/76e88b45-b86c-405f-8fac-7dcc35da2661)


- remove snapshot1
```
virsh snapshot-delete server2 --snapshotname snapshot1
virsh snapshot-list server2
```

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/02ef8711-d212-4945-9ba8-cc8f7f2055e1)

