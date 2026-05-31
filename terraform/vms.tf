locals {
  scripts   = path.module
  source_vm = "ubunta"
}

resource "null_resource" "worker" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "& '${local.scripts}\\create-vm.ps1' -VmName '${var.worker_name}' -Memory 2048 -Cpus 2 -HostIf '${var.host_only_if}' -SourceVm '${local.source_vm}'"
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["PowerShell", "-Command"]
    command     = "& 'C:\\Users\\user\\lab4\\terraform\\destroy-vm.ps1' -VmName 'lab4-worker'"
  }
}

resource "null_resource" "db" {
  provisioner "local-exec" {
    interpreter = ["PowerShell", "-Command"]
    command     = "& '${local.scripts}\\create-vm.ps1' -VmName '${var.db_name}' -Memory 1024 -Cpus 1 -HostIf '${var.host_only_if}' -SourceVm '${local.source_vm}'"
  }

  provisioner "local-exec" {
    when        = destroy
    interpreter = ["PowerShell", "-Command"]
    command     = "& 'C:\\Users\\user\\lab4\\terraform\\destroy-vm.ps1' -VmName 'lab4-db'"
  }
}
