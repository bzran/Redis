provider "alicloud" {
  region = "cn-beijing"
  version = "=1.118.0"
}

variable "creation" {
  default = "KVStore"
}

variable "name" {
  default = "kvstoreinstancevpc"
}

data "alicloud_zones" "default" {
  available_resource_creation = var.creation
}

resource "alicloud_vpc" "default" {
  name       = var.name
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "default" {
  vpc_id            = alicloud_vpc.default.id
  cidr_block        = "172.16.0.0/24"
  availability_zone = data.alicloud_zones.default.zones[0].id
  name              = var.name
}

resource "alicloud_kvstore_instance" "example" {
  db_instance_name      = "tf-test-basic"
  vswitch_id            = alicloud_vswitch.default.id
  security_ips          = [
    "10.23.12.24"]
  instance_type         = "Redis"
  engine_version        = "4.0"
  config = {
    appendonly = "yes",
    lazyfree-lazy-eviction = "yes",
  }
  tags = {
    Created = "TF",
    For = "Test",
  }
  zone_id               = "cn-beijing-h"
  instance_class        = "redis.master.large.default"
}

resource "alicloud_kvstore_connection" "default" {
  connection_string_prefix  = "allocatetestupdate"
  instance_id               = alicloud_kvstore_instance.example.id
  port                      = "6370"
}

resource "alicloud_kvstore_account" "example" {
  account_name     = "tftestnormal"
  account_password = "YourPassword_123"
  instance_id      = alicloud_kvstore_instance.example.id
}