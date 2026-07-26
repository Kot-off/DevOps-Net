locals {
  ssh_key = file(var.vms_ssh_public_key_path)
}