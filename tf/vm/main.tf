provider "proxmox" {

pm_api_url = var.proxmox_host["pm_api_url"]

pm_api_token_id = var.proxmox_host["pm_api_token_id"]

pm_api_token_secret = var.proxmox_host["pm_api_token_secret"]

pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "prox-vm"{
  count = length(var.hostnames)
  name = var.hostnames[count.index]
  target_node = var.proxmox_host["target_node"]
  vmid = var.vmid + count.index
  full_clone = true
  clone = "ubuntu-cloud"
  ci_wait = 40
 
  cores = 2
  sockets = 2
  memory = 8192
  
  boot = "order=scsi0;ide0"

  scsihw = "virtio-scsi-pci"
  cloudinit_cdrom_storage = "zfslocal"
 
  agent = 1
  cpu = "host"
  numa = true

  
  network {
    bridge = "vmbr0"
    model = "virtio"
  }
  
  ipconfig0 =  "ip=${var.ips[count.index]}/24,gw=${cidrhost(format("%s/24", var.ips[count.index]), 1)}"


  
   disks {
        scsi {
            scsi0 {
                disk {
                    size = 40
                    storage = "zfslocal"
                }
            }
        }
        ide {
            ide0 {
                disk {
                    size = 40
                    storage = "zfslocal"
                  }
              }
           }
	}


  os_type = "cloud-init"

 
  
  #creates ssh connection to check when the CT is ready for ansible provisioning
  connection {
    
    type = "ssh"
    host = var.ips[count.index]
    user = var.user
    private_key = file(var.ssh_keys["priv"])
    agent = false
    timeout = "3m"
  }

  provisioner "remote-exec" {
	  # Leave this here so we know when to start with Ansible local-exec 
    inline = [ "echo 'Cool, we are ready for provisioning'"]
  }


  provisioner "local-exec" {
      working_dir = "../../ansible/"
      command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, provision-vm.yaml"
  }

  provisioner "local-exec" {
      working_dir = "../../ansible/"
      command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, docker.yaml"
  }


  provisioner "local-exec" {
      working_dir = "../../ansible/"
      command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, nvidia.yaml"
  }


    provisioner "local-exec" {
      working_dir = "../../ansible/"
      command = "ansible-playbook -u ${var.user} --key-file ${var.ssh_keys["priv"]} -i ${var.ips[count.index]}, cuda-image-dlc.yaml"
  }


}


