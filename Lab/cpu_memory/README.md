# Expand Memory/Ram
- check memory/ram (Server1)
```
ssh 10.20.10.10
free -h
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/f25564a0-ed97-43a7-902b-a329e7b25211)


- ganti Max Memory di vm
untuk expand memory menjadi lebih besar, sebelumnya kita harus max memory di vm tersebut. Kita tidak dapat set memory diatas dari max memory
```
virsh dominfo server1 | grep "Max memory"
virsh shutdown
virsh dominfo server1 | grep "Max memory"
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/6940ef2b-4cae-4151-bb23-8390662b1a71)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/0323d033-f355-4b5c-a09d-e1c1f7e04345)


- ganti memory/ram 4G to 8G
untuk mengganti memory di server, kita tidak perlu shutdown server. Hanya pada bagian ganti max memory saja yang perlu state server shutdown
```
virsh start server1
virsh setmem server1 8192M --current
virsh dominfo server1 | grep memory
```

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/44ce4959-e975-4e7a-bba1-10d85af701e5)


- verify
```
ssh 10.20.10.10 # vm server1
free -h
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/b79a2f09-ddb3-42ac-a119-b762edc9bc5c)

> # note
> jika kalian ingin menurunkan memory bisa set memory ke lebih rendah, tidak perlu set maxmemory lagi, Agar ketika kita ingin expand lagi tidak perlu set max memorynya

# expand cpu
- check cpu
```
virsh dominfo server1
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/6cf27b8d-d9ea-4806-aa67-4b9c09c5140b)


- expand cpu from 2 to 4
```
virsh shutdown server1
virsh setvcpus server1 4 --config --maximum # set maximum cpu 
virsh setvcpus server1 4 --config # set cpu
```

- verify 
```
virsh dominfo server1
virsh start server1
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/63551eae-845b-471b-a739-f8e61f2f8def)

remote server1
```
ssh 10.20.10.10
nproc
htop
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/7f807af7-e8a6-470b-a7e4-f40e19e872ff)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/d6444d41-44ec-41fd-a11c-04ae076ff513)

