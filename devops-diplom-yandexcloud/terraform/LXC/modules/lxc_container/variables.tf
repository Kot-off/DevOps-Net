variable "target_node"          {}
variable "vm_id"               {}
variable "hostname"            {}
variable "ip_address"          {}
variable "gateway"             { default = "192.168.1.1" }
variable "container_password"  {}
variable "template_id"         {}
variable "os_type"             {}
variable "ssh_public_key"      {}
variable "ssh_private_key_path" {}
variable "ssh_user"            { default = "root" }
variable "copy_private_key"     { 
  type = bool
  default = false 
}
variable "setup_commands"       { 
  type = list(string)
  default = [] 
}