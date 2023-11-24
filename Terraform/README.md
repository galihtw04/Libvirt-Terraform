# TERRAFORM

- install package
```
sudo apt update && sudo apt -y install wget curl unzip
```
- Download binary terraform [repo_terraform](https://github.com/hashicorp/terraform/releases)
```
TER_VER=`curl -s https://api.github.com/repos/hashicorp/terraform/releases/latest | grep tag_name | cut -d: -f2 | tr -d \"\,\v | awk '{$1=$1};1'`
wget https://releases.hashicorp.com/terraform/${TER_VER}/terraform_${TER_VER}_linux_amd64.zip
```

- ekstrak terraform
```
unzip terraform_${TER_VER}_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

- Vwrifkasi terraform

```
terraform version
libvirtd --version
virsh -c qemu:///system version
```

# Lanjut ke testing
Untuk melakukan testing kita perlu mempersiapkan enviroment untuk server kita nanti,

- create storage image
storage image digunakan untuk menyimpan image os, ini memudahkan kita agar ketika membuat suatu vm/instance tidak perlu mendefinisikan path images berada.
```
mkdir /data-images
virsh pool-define-as data-images dir - - - - "/data-images"
virsh pool-build data-images
virsh pool-start data-images
virsh pool-autostart data-images
```

- verify pool images
```
virsh pool-list
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/3ff103a0-3626-486e-b150-31ba489753a2)

- create storage disk
digunakan untuk menyimpan disk server kita, disk ini seperti (vmdk di vmware)

```
mkdir /data-disk
virsh pool-define-as data-disk dir - - - - "/data-disk"
virsh pool-build data-disk
virsh pool-start data-disk
virsh pool-autostart data-disk
```

- verify
```
virsh pool-info data-disk
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/7d3f24b6-ca2d-432e-95d4-27c58c96b027)

- Download binary tvgen
tvgen kita gunakan untuk membantu kita membuild server
```
git clone git@github.com:galihtw04/kvm-libvirt.git
cp -R kvm-libvirt/Terraform/notvgen/* .
chmod +x notvgen.sh 
ls -l
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/71de46b6-c6f0-4ea7-a281-7aef10ab91fd)

- create template server
```
nano server.txt
```

```
[LAB]
PUBKEY1: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDARLWkbIGnuEyjqe27ZO61WfrxhOkffoAfJCOWTwFWDTIN+cNXoaT1hqer/W6U2iMXISzA0LQRgQG27Xcew7gBmrpWBSO4UUWZT2r46l+2BkZsV3x0oFeAR4LQFgC//o6Q7CtCjOohsqdcKXT7eE5wTOF6bwF/oix5BODmMGH/fS4WkE1lo8wZVF/MDJegGGDdRxifC/B5yf2GbHwJh6rQrSrRCt2/D67tojN8l1XI7QCUAEvMkC48Jo13Jk1PBrlIRFUisha/SBrOwtIbOEl8Bc1c52ZN3B2E4T6UkVjRZMz0Rmm2U+0+khOicGLvYjFIhf3EUPMIa/im8TtY/WeNg4X8Ari1c375aV75s8fueP2TRAU3xufwAo+RqRQ1YwDAdgOo2va5YYf1QGMiBMX1WlZjQwuoIYCjZQokN1Ytq75HJj21KkxOHWPPum8L6MDQt5XxGiH3QRcISae0O/MrdzNExTMDWRqOxY8NMvpb8hK+64yJyykDYuS5F5gXHmc= root@server-1

[VM1]
NAME: server1
OS: ubuntu-jammy.img
NESTED: n
VCPUS: 2
MEMORY: 4G
DISK1: 50G
DISK2: 20G
IFACE_NETWORK1: default # network default
IFACE_IP1: 192.168.122.10
IFACE_NETWORK2: net-10.20.10.0 # network baru net-10.20.10
IFACE_IP2: 10.20.10.10
CONSOLE: vnc

[VM2]
NAME: server2
OS: ubuntu-jammy.img
NESTED: n
VCPUS: 2
MEMORY: 4G
DISK1: 50G
IFACE_NETWORK1: net-10.20.10 # network baru net-10.20.10
IFACE_IP1: 10.20.10.11
CONSOLE: vnc

```

- upload ubuntu-jammy to storage data-images
disini kita akan upload image ubuntu22 ke data-storage, image ubuntu akan digunakan oleh server kita.

```
cp ~/qemu/jammy-server-cloudimg-amd64.img /data-images/ubuntu-jammy.img
virsh pool-refresh --pool data-images
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/74ad8665-08ed-42b8-8c4b-2561733ece19)

- create network net-10.20.10
```
nano net-10.20.10.xml
```
## internet network
```
<network>
  <name>net-10.20.10</name>
  <forward mode='nat'/>
  <bridge name='vmnet01' stp='on' delay='0'/>
  <ip address='10.20.10.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='10.20.10.2' end='10.20.10.254' />
    </dhcp>
  </ip>
</network>
```

## isolated network
```
<network>
  <name>net-10.20.10</name>
  <forward mode='route'/>
  <bridge name='vmnet01' stp='on' delay='0'/>
  <ip address='10.20.10.1' netmask='255.255.255.0' localPtr='yes'>
    <dhcp>
      <range start='10.20.10.2' end='10.20.10.254' />
    </dhcp>
  </ip>
</network>
```

apply netowrk net-10.20.10, pilih salah satu dari konfigurasi diatas bisa pakai isolated atau public
```
virsh net-define net-10.20.10.xml
virsh net-start net-10.20.10
virsh net-autostart net-10.20.10
```

verify net-10.20.10
```
virsh net-list
virsh net-dumpxml
```
![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/c4ed38a5-0296-4d33-9c07-3ce7430f724c)

- create server instance/vm using terraform
```
ls -l
./notvgen server server.txt
ls -l
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/51310a3e-a5d0-4064-b902-9325f8dc6500)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/7dc0f4fb-4cc1-4ab0-ba20-6bfcce28388e)

create server instance
```
cd server
ls -l
terraform init
terraform apply -auto-approve
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/e3de4c7d-d43c-4a08-ae6f-2de4bf409a8a)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/24d9336b-6931-4d0e-a6fe-d415c0c9a001)

- verify akses with ssh
```
ssh 10.20.10.10
ip -br a
```

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/1b54b1e4-b805-42e8-8b4f-03817c5c2f18)

![image](https://github.com/galihtw04/kvm-libvirt/assets/96242740/9bcaa2a7-e93e-4f43-968a-1957a9ff7d90)
