// PowerVC connection
//********************
provider "openstack" {
  user_name = "${var.user_name}"
  password = "${var.password}"
  tenant_name = "${var.tenant_name}"
  domain_name = "${var.domain_name}"
  auth_url = "${var.auth_url}"
  insecure = "${var.insecure}"
}

// Init master node
//********************
resource "openstack_compute_instance_v2" "master_init" {
  name = "master.ocp"
  image_name  = "${var.image_name}"
  flavor_name = "${var.master.flavor_name}"

  network {
    name = "${var.network_name}"
		fixed_ip_v4 = "${var.master.fixed_ip_v4}"
  }
}

// Init worker nodes
//********************
resource "openstack_compute_instance_v2" "worker_init" {
  depends_on = ["openstack_compute_instance_v2.master_init"] 
  count = "${var.worker.nodes}"
  name = "worker${count.index+1}.ocp"
  image_name  = "${var.image_name}"
  flavor_name = "${var.worker.flavor_name}"

  network {
    name = "${var.network_name}"
		fixed_ip_v4 = "X.X.X.${local.master_ip_last_octet + count.index + 1}" // EDIT
  }

}

// Transfer and run install scripts
// Worker nodes
//********************
resource "null_resource" "worker_config" {
  depends_on = ["openstack_compute_instance_v2.master_init"]
  count = "${var.worker.nodes}" 
  connection {
    host = "worker${count.index+1}.ocp"
    port = "22"
    user = "root"
    private_key = "${file("./id_rsa")}"
    timeout = "15m"
  }

  provisioner "file" {
    source = "scripts/rhel_prepare.sh"
    destination = "/tmp/rhel_prepare.sh"
    }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/rhel_prepare.sh",
      "/tmp/rhel_prepare.sh",
      "yum -y install cockpit cockpit-kubernetes" ]
  }

  provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "subscription-manager unregister",
            "subscription-manager remove --all",
        ]
    }
}

// Master node
//********************
resource "null_resource" "master_config" {
  depends_on = ["null_resource.worker_config"]
  connection {
    host = "master.ocp"
    port = "22"
    user = "root"
    private_key = "${file("./id_rsa")}"
    timeout = "15m"
  }

  provisioner "file" {
    source = "scripts/rhel_prepare.sh"
    destination = "/tmp/rhel_prepare.sh"
    }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/rhel_prepare.sh",
      "/tmp/rhel_prepare.sh" ]
  }

  provisioner "file" {
    source = "scripts/prepare_ssh_keys.sh"
    destination = "/tmp/prepare_ssh_keys.sh"
    }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/prepare_ssh_keys.sh",
      "/tmp/prepare_ssh_keys.sh" ]
  }

  provisioner "file" {
    source = "scripts/openshift_install.sh"
    destination = "/tmp/openshift_install.sh"
    }

  provisioner "remote-exec" {
    inline = [ 
      "chmod +x /tmp/openshift_install.sh",
      "/tmp/openshift_install.sh" ]
  }

  provisioner "remote-exec" {
        when = "destroy"
        inline = [
            "subscription-manager unregister",
            "subscription-manager remove --all",
        ]
    }
}

// Local variables
//********************
locals {
  master_ip_last_octet = "${element(split(".", var.master.fixed_ip_v4), 3)}"
}