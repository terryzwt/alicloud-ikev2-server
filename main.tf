data "alicloud_instance_types" "instance_type" {
  instance_type_family = "ecs.xn4"
  cpu_core_count       = "1"
  memory_size          = "1"
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
  available_instance_type     = "${data.alicloud_instance_types.instance_type.instance_types.0.id}"
}

resource "alicloud_vpc" "main" {
  vpc_name       = "vpc-${var.short_name}"
  cidr_block = "10.1.0.0/21"
}

resource "alicloud_vswitch" "main" {
  vpc_id            = "${alicloud_vpc.main.id}"
  cidr_block        = "10.1.1.0/24"
  zone_id           = "${data.alicloud_zones.default.zones.0.id}"
}

resource "alicloud_security_group" "group" {
  name        = "group-${var.short_name}"
  description = "New security group"
  vpc_id      = "${alicloud_vpc.main.id}"
}
resource "alicloud_security_group_rule" "allow_http_80" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "${var.nic_type}"
  policy            = "accept"
  port_range        = "80/80"
  priority          = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip           = "0.0.0.0/0"
}
resource "alicloud_security_group_rule" "allow_all" {
  type              = "ingress"
  ip_protocol       = "all"
  nic_type          = "${var.nic_type}"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_https_22" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "${var.nic_type}"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = "${alicloud_security_group.group.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_key_pair" "key_pair" {
  key_pair_name = "${var.key_name}"
  //key_file = "${var.private_key_file}"
  public_key = "${var.public_key}"
}

resource "alicloud_instance" "instance" {
  instance_name   = "${var.short_name}-${format(var.count_format, count.index+1)}"
  host_name       = "${var.short_name}-${format(var.count_format, count.index+1)}"
  image_id        = "${var.image_id}"
  instance_type   = "${data.alicloud_instance_types.instance_type.instance_types.0.id}"
  count           = "${var.ecs_count}"
  security_groups = ["${alicloud_security_group.group.id}"]

  internet_charge_type       = "${var.internet_charge_type}"
  internet_max_bandwidth_out = "${var.internet_max_bandwidth_out}"

  password = "${var.ecs_password}"
  key_name = "${alicloud_key_pair.key_pair.id}"

  instance_charge_type = "PostPaid"
  system_disk_category = "${var.disk_category}"

  vswitch_id = "${alicloud_vswitch.main.id}"
  
  //for ansible
  connection {
    user = "root"
    host = "${self.public_ip}"
    host_key = "~/.ssh/id_rsa"
  }
  provisioner "ansible" {
    plays {
      playbook {
        file_path = "${path.module}/ansible/ikev2-packer-custom-image.yml"
        roles_path = [
            "${path.module}/ansible/roles"
        ]
      }
      hosts = ["${alicloud_instance.instance.0.public_ip}"]
    }
    ansible_ssh_settings {
      insecure_no_strict_host_key_checking = "${var.insecure_no_strict_host_key_checking}"
    }
  }
 
}

resource "alicloud_disk" "disk" {
  zone_id = "${alicloud_instance.instance.0.availability_zone}"
  category          = "${var.disk_category}"
  size              = "${var.disk_size}"
  count             = "${var.disk_count}"
}

resource "alicloud_disk_attachment" "instance-attachment" {
  count       = "${var.disk_count}"
  disk_id     = "${var.disk_count}"
  instance_id = "${var.disk_count}"
}
