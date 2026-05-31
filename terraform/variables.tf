variable "worker_name" { default = "lab4-worker" }
variable "db_name"     { default = "lab4-db" }
variable "worker_ip"   { default = "192.168.56.20" }
variable "db_ip"       { default = "192.168.56.21" }
variable "host_only_if" { default = "VirtualBox Host-Only Ethernet Adapter" }
variable "box_url" {
  default = "https://app.vagrantup.com/ubuntu/boxes/focal64/versions/20230119.0.0/providers/virtualbox.box"
}
