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
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/26a2846e-6eee-4903-83f2-fc439ed1f5e5)


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
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/12d579e1-9461-4d07-a59e-e019d2481632)


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
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/9a34b75b-c3c5-4fcc-9dea-7010549a35ef)


- create server instance/vm using terraform
```
ls -l
./notvgen server server.txt
ls -l
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/e33ea527-6efe-4d90-926a-11816bcd9d6a)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/a34c2516-354e-479b-80fc-b87a34eff421)


create server instance
```
cd server
ls -l
terraform init
terraform apply -auto-approve
```

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/76c8855a-91f6-48a7-bc41-22c9e2d55115)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/36084478-fab5-4e0c-9d00-2f1b9a1078b0)


- verify akses with ssh
```
ssh 10.20.10.10
ip -br a
```
![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/eaa329b4-bcb7-4573-a78a-7efd6e5b9c95)

![image](https://github.com/galihtw04/Libvirt-Terraform/assets/96242740/3c50f26c-e888-48de-8e02-50500c9ad9d3)

