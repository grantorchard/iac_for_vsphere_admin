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
# DISCOVER RESOURCES
# A number of resources in our environment are not managed by Terraform, so here we discover them to use as inputs to
# other resources in this definition.
# Note that although in this environment these resources are unmanaged, it doesn't mean that they aren't valid resource
# types. Please look at https://www.terraform.io/docs/providers/vsphere/ to see a full list of vSphere resources.
# ---------------------------------------------------------------------------------------------------------------------

data "vsphere_datacenter" "regiona01" {
  name = "RegionA01"
}

data "vsphere_resource_pool" "regiona01-compute-resources" {
  name          = "RegionA01-Compute/Resources"
  datacenter_id = "${data.vsphere_datacenter.regiona01.id}"
}

data "vsphere_datastore" "regiona01-iscsi-01-comp01" {
  name          = "RegionA01-ISCSI01-COMP01"
  datacenter_id = "${data.vsphere_datacenter.regiona01.id}"
}

data "vsphere_network" "vm-network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.regiona01.id}"
}

data "vsphere_virtual_machine" "base-linux-cli" {
  name          = "base-linux-cli"
  datacenter_id = "${data.vsphere_datacenter.regiona01.id}"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY VIRTUAL MACHINE
# Cloning from the base-linux-cli template. 
# ---------------------------------------------------------------------------------------------------------------------

resource "vsphere_virtual_machine" "tf-01a" {
  name             = "tf-01a"
  resource_pool_id = "${data.vsphere_resource_pool.regiona01-compute-resources.id}"
  datastore_id     = "${data.vsphere_datastore.regiona01-iscsi-01-comp01.id}"

  num_cpus = 2
  memory   = 1024

  guest_id = "${data.vsphere_virtual_machine.base-linux-cli.guest_id}"

  network_interface {
    network_id   = "${data.vsphere_network.vm-network.id}"
  }

  disk {
    name = "tf-01a.vmdk"
    size = "10"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.base-linux-cli.id}"

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