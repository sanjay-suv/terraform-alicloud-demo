terraform {
  backend "s3" {
    bucket   = "tfstate"
    key      = "demo/terraform.tfstate"
    region   = "us-east-1"
    endpoint = "https://oss-eu-central-1.aliyuncs.com"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_get_ec2_platforms      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
  }
}

data "alicloud_instance_types" "2c4g" {
  cpu_core_count = 2
  memory_size    = 4
}

resource "alicloud_vpc" "vpc" {
  name       = "tf_test_foo"
  cidr_block = "172.16.0.0/12"
}

# Create security group
resource "alicloud_security_group" "default" {
  name        = "default"
  description = "default"
  vpc_id      = "${alicloud_vpc.vpc.id}"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = "${alicloud_vpc.vpc.id}"
  cidr_block        = "172.16.0.0/21"
  availability_zone = "eu-central-1a"
}

# Create a web server
resource "alicloud_instance" "web" {
  # cn-beijing
  image_id             = "ubuntu_140405_32_40G_cloudinit_20161115.vhd"
  internet_charge_type = "PayByBandwidth"

  instance_type        = "${data.alicloud_instance_types.2c4g.instance_types.0.id}"
  system_disk_category = "cloud_efficiency"
  security_groups      = ["${alicloud_security_group.default.id}"]
  instance_name        = "web"
  vswitch_id           = "${alicloud_vswitch.vsw.id}"
}
