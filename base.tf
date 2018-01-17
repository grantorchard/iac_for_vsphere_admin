# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A VIRTUAL MACHINE ON VMWARE VSPHERE
# ---------------------------------------------------------------------------------------------------------------------

provider "vsphere" {
  user                 = "administrator@vsphere.local"
  password             = "VMware1!"
  vsphere_server       = "vcsa-01a.corp.local"
  allow_unverified_ssl = true
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY VIRTUAL MACHINE
# Cloning from the base-linux-cli template. 
# ---------------------------------------------------------------------------------------------------------------------

resource "vsphere_virtual_machine" "tf-01a" {
  name             = "tf-01a"
  resource_pool_id = "resgroup-102"
  datastore_id     = "datastore-61"

  num_cpus = 2
  memory   = 1024

  guest_id = "centos64Guest"

  network_interface {
    network_id   = "network-781"
    adapter_type = "vmxnet3"
  }

  disk {
    name = "tf-01a.vmdk"
    size = "10"
  }

  clone {
    template_uuid = "4208c2fc-55c2-5534-2336-2d6625fcef89"

    customize {
      linux_options {
        host_name = "tf-01a"
        domain    = "corp.local"
      }

      network_interface {
        ipv4_address = "192.168.110.202"
        ipv4_netmask = 24
      }

      ipv4_gateway    = "192.168.110.1"
      dns_server_list = ["192.168.110.10"]
    }
  }
}