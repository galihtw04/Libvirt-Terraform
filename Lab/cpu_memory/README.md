# Expand Memory/Ram
- check memory/ram (Server1)
```
free -h
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/cfae18a6-1650-4c16-87de-4fb49071a30f)

- ganti Max Memory di vm
untuk expand memory menjadi lebih besar, sebelumnya kita harus max memory di vm tersebut. Kita tidak dapat set memory diatas dari max memory
```
virsh dominfo server1 | grep "Max memory"
virsh shutdown
virsh dominfo server1 | grep "Max memory"
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/47167897-8487-4d04-84ea-4eaf5210f097)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/33bc6406-2e20-4b1f-b4f6-2c041d71ca6d)

- ganti memory/ram 4G to 8G
untuk mengganti memory di server, kita tidak perlu shutdown server. Hanya pada bagian ganti max memory saja yang perlu state server shutdown
```
virsh start server1
virsh setmem server1 8192M --current
virsh dominfo server1 | grep memory
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/07033e41-f28e-4cb2-8dba-b137bd068f14)

- verify
```
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
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/4fd9a878-3217-4141-b6ab-58f4d70c8fab)

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
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/b8e5ea9d-0713-48b9-be1a-de5dfe2437b1)

remote server1
```
ssh 10.20.10.10
nproc
htop
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/241e8faa-dc08-4509-b4f0-8d5f14766ab4)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/834fe11a-aaf5-416b-a59b-58aa9f223757)
