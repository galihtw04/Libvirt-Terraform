
# kvm-libvirt

# install qemu/kvm di ubuntu

- Pertama pastikan server kalian support kvm
```
apt install cpu-checker -y
kvm-ok
```
notice
```
INFO: /dev/kvm exists
KVM acceleration can be used
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/b1f0d797-af65-41a0-8e64-45a79a0214c8)


- install kvm/qemu
```
sudo apt update && \
sudo apt -y install qemu-kvm libvirt-daemon bridge-utils virtinst libvirt-daemon-system \
virt-top libguestfs-tools libosinfo-bin  qemu-system virt-manager cloud-image-utils bridge-utils
```

- set modprobe
```
sudo modprobe vhost_net 
lsmod | grep vhost
echo vhost_net | sudo tee -a /etc/modules
```

- setup user and group, set permission ke root
```
nano /etc/libvirt/qemu.conf
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/efce2326-257d-48de-9dc2-f70c142bec51)

- set apparmor

```
nano  /etc/apparmor.d/libvirt/TEMPLATE.qemu
```

```
#include <tunables/global>
profile LIBVIRT_TEMPLATE flags=(attach_disconnected) {
  #include <abstractions/libvirt-qemu>
  /**.qcow{,2} rwk,
  /**.img rwk,
}
```

- apply and reload service
```
apparmor_parser -r /etc/apparmor.d/libvirt/TEMPLATE.qemu
systemctl reload apparmor
```

- create network bridge
```
sudo ip -br a
nano /etc/netplan/00-installer-config.yaml
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/ee5d7ccc-38ff-4a80-97dc-53b0970d18ad)

```
  bridges:
    br0:
      interfaces: [ens160] #sesuaikan dengan nama interface kalian
      addresses: [192.168.210.4/24] # gunakan ip yang tidak terpakai
      gateway4: 192.168.210.1
      mtu: 1500
      nameservers:
        addresses: [1.1.1.1, 8.8.8.8]
      parameters:
        stp: true
        forward-delay: 4
      dhcp4: no
      dhcp6: no
```

- simpan konfigurasi netplan, selanjutnya apply
```
netplan apply
ip -br a
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/d616689c-df25-4b8d-9533-6edeaa1c0b88)

- Untuk setup qemu sudah selesai, sekarang kita akan coba membuat 1 vm
- selanjutnya kita akan coba download image ubuntu 

```
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

qemu-img info jammy-server-cloudimg-amd64.img
qemu-img resize jammy-server-cloudimg-amd64.img 10G 
qemu-img info jammy-server-cloudimg-amd64.img

qemu-img convert -f qcow2 jammy-server-cloudimg-amd64.img ubuntu-jammy.img
```

- buat user data untuk aksess vm nanti
```
#cloud-config
ssh_pwauth: true
disable_root: false

chpasswd:
  list: |
    root:password
    tshoot:recovery
  expire: false

users:
  - name: root
    shell: /bin/bash
    ssh-authorized-keys:
# ganti dengan id_rsa.pub server kalian
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDARLWkbIGnuEyjqe27ZO61WfrxhOkffoAfJCOWTwFWDTIN+cNXoaT1hqer/W6U2iMXISzA0LQRgQG27Xcew7gBmrpWBSO4UUWZT2r46l+2BkZsV3x0oFeAR4LQFgC//o6Q7CtCjOohsqdcKXT7eE5wTOF6bwF/oix5BODmMGH/fS4WkE1lo8wZVF/MDJegGGDdRxifC/B5yf2GbHwJh6rQrSrRCt2/D67tojN8l1XI7QCUAEvMkC48Jo13Jk1PBrlIRFUisha/SBrOwtIbOEl8Bc1c52ZN3B2E4T6UkVjRZMz0Rmm2U+0+khOicGLvYjFIhf3EUPMIa/im8TtY/WeNg4X8Ari1c375aV75s8fueP2TRAU3xufwAo+RqRQ1YwDAdgOo2va5YYf1QGMiBMX1WlZjQwuoIYCjZQokN1Ytq75HJj21KkxOHWPPum8L6MDQt5XxGiH3QRcISae0O/MrdzNExTMDWRqOxY8NMvpb8hK+64yJyykDYuS5F5gXHmc= root@server-1

  - name: tshoot
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    lock_passwd: false
    groups: users, wheel, sudo
    ssh-authorized-keys:
# ganti dengan id_rsa.pub server kalian
      - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDARLWkbIGnuEyjqe27ZO61WfrxhOkffoAfJCOWTwFWDTIN+cNXoaT1hqer/W6U2iMXISzA0LQRgQG27Xcew7gBmrpWBSO4UUWZT2r46l+2BkZsV3x0oFeAR4LQFgC//o6Q7CtCjOohsqdcKXT7eE5wTOF6bwF/oix5BODmMGH/fS4WkE1lo8wZVF/MDJegGGDdRxifC/B5yf2GbHwJh6rQrSrRCt2/D67tojN8l1XI7QCUAEvMkC48Jo13Jk1PBrlIRFUisha/SBrOwtIbOEl8Bc1c52ZN3B2E4T6UkVjRZMz0Rmm2U+0+khOicGLvYjFIhf3EUPMIa/im8TtY/WeNg4X8Ari1c375aV75s8fueP2TRAU3xufwAo+RqRQ1YwDAdgOo2va5YYf1QGMiBMX1WlZjQwuoIYCjZQokN1Ytq75HJj21KkxOHWPPum8L6MDQt5XxGiH3QRcISae0O/MrdzNExTMDWRqOxY8NMvpb8hK+64yJyykDYuS5F5gXHmc= root@server-1
```

- create userdate
```
sudo cloud-localds user.iso init.txt
```

- buat 1 default
- dibawah kita membuat vm dengan nama ubuntu test dengan memory 2048
- disk ubuntuk-jammy.img sesuai dengan nama image yang telah kita buat pada bagian download image, dan sesusaujan os-variant dengna image yang kalian gunakan
- dan untuk network didapat dari *virsh net-list*
```
sudo virt-install \
--name ubuntu-server \
--memory 2048 \
--disk ubuntu-jammy.img,device=disk,bus=virtio \
--disk common-init.iso,device=cdrom \
--os-type linux \
--os-variant ubuntu22.10 \
--virt-type qemu \
--graphics none \
--network network=default,model=virtio \
--import
```

* Jika mau keluar dari console bisa menggunakan shortcut *CTRL + ]*

- verify vm
```
virsh list
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/fa5d259c-34e3-492f-a190-a24801a2afb7)

- shutdown server
```
virsh shutdown --domain ubuntu-server

Domain 'ubuntu-server' is being shutdown
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/d3966283-7889-43f9-9b81-f80cb8aa25a6)

- start server
```
virsh start --domain ubuntu-server
Domain 'ubuntu-server' started
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/5ed15b93-845f-4156-8c31-6785c6ea2e59)

- delete server
```
virsh shutdown --domain ubuntu-server
Domain 'ubuntu-server' is being shutdown

virsh undefine --domain ubuntu-server
Domain 'ubuntu-server' has been undefined

virsh undefine --domain ubuntu-server
Domain 'ubuntu-server' has been undefined
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/402abf00-1a41-4a58-8bc9-0da6ba8cf2fc)

> # lanjut ke terraform kawan
