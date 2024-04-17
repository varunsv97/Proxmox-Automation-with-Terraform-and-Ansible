variable "proxmox_host" {
	type = map
       default = {
       pm_api_url = "https://134.34.206.**:8006/api2/json"
       pm_api_token_id = "terraform-prov@pve!terraform-api-token"
       pm_api_token_secret = "7dad3995***************ece84e8dcd"
     
       target_node = "pve"
     }
}

variable "vmid" {
	default     = 9235
	description = "Starting ID for the VMs"
}


variable "hostnames" {
  description = "VMs to be created"
  type        = list(string)
  default     = ["VM-DeepLabCutDemo1"]
}

variable "rootfs_size" {
	default = "2G"
}

variable "ips" {
    description = "IPs of the VMs, respective to the hostname order"
    type = list(string)
    default = ["134.34.206.235"]
}

variable "ssh_keys" {
	type = map
     default = {
       pub  = "~/.ssh/id_rsa.pub"
       priv = "~/.ssh/id_rsa"
     }
}



variable "user" {
	default     = "ubuntu"
	description = "User used to SSH into the machine and provision it"
}
