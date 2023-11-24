provider "libvirt" {
    uri = "qemu:///system"
}

terraform {
 required_version = ">= 0.13"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
    }
  }
}
    
resource "libvirt_cloudinit_disk" "server1-cloudinit" {
    name = "server1-cloudinit.iso"
    pool = "data-disk"
    user_data = data.template_file.user1_data.rendered
    network_config = data.template_file.network1_config.rendered
}
    
data "template_file" "user1_data" {
    template = file("${path.module}/cloudinit1.cfg")
}
    
data "template_file" "network1_config" {
    template = file("${path.module}/network1_config.cfg")
}

resource "libvirt_volume" "server1-vda" {
    name = "server1-vda.qcow2"
    pool = "data-disk"
    base_volume_name = "ubuntu-jammy.img"
    base_volume_pool = "data-images"
    size = "53687091200"
    format = "qcow2"
}

resource "libvirt_volume" "server1-vdb" {
    name = "server1-vdb.qcow2"
    pool = "data-disk"
    size = "21474836480"
    format = "qcow2"
}

resource "libvirt_domain" "server1" {
    name = "server1"
    memory = "4096"
    vcpu = "2"

    cpu {
           mode = "host-passthrough"
    }

    cloudinit = libvirt_cloudinit_disk.server1-cloudinit.id

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_port = "1"
        target_type = "virtio"
    }

    network_interface {
        network_name = "default"
        addresses = ["192.168.122.10"]
    }

    network_interface {
        network_name = "net-10.20.10"
        addresses = ["10.20.10.10"]
    }

    disk {
        volume_id = libvirt_volume.server1-vda.id
    }

    disk {
        volume_id = libvirt_volume.server1-vdb.id
    }

    video {
        type = "vga"
    }
    
    graphics {
        type = "vnc"
        listen_type = "address"
        autoport = true
    }
}

resource "libvirt_cloudinit_disk" "server2-cloudinit" {
    name = "server2-cloudinit.iso"
    pool = "data-disk"
    user_data = data.template_file.user2_data.rendered
    network_config = data.template_file.network2_config.rendered
}
    
data "template_file" "user2_data" {
    template = file("${path.module}/cloudinit2.cfg")
}
    
data "template_file" "network2_config" {
    template = file("${path.module}/network2_config.cfg")
}

resource "libvirt_volume" "server2-vda" {
    name = "server2-vda.qcow2"
    pool = "data-disk"
    base_volume_name = "ubuntu-jammy.img"
    base_volume_pool = "data-images"
    size = "53687091200"
    format = "qcow2"
}

resource "libvirt_domain" "server2" {
    name = "server2"
    memory = "4096"
    vcpu = "2"

    cpu {
           mode = "host-passthrough"
    }

    cloudinit = libvirt_cloudinit_disk.server2-cloudinit.id

    console {
        type        = "pty"
        target_port = "0"
        target_type = "serial"
    }

    console {
        type        = "pty"
        target_port = "1"
        target_type = "virtio"
    }

    network_interface {
        network_name = "net-10.20.10"
        addresses = ["10.20.10.11"]
    }

    disk {
        volume_id = libvirt_volume.server2-vda.id
    }

    video {
        type = "vga"
    }
    
    graphics {
        type = "vnc"
        listen_type = "address"
        autoport = true
    }
}
