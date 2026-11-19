terraform {
  required_version = ">= 1.6.0"
}

locals {
  maquinas = {
    vm1 = {
      nome      = "avaliacao-vm1-web"
      ram       = 2048
      disco_mb  = 15360
      porta_ssh = 2221
      porta_app = 8181
      seed      = "seed-vm1.iso"
    }

    vm2 = {
      nome      = "avaliacao-vm2-api"
      ram       = 4096
      disco_mb  = 20480
      porta_ssh = 2222
      porta_app = 3000
      seed      = "seed-vm2.iso"
    }
  }
}

resource "terraform_data" "vm" {
  for_each = local.maquinas

  input = each.value

  provisioner "local-exec" {
    working_dir = path.module
    interpreter = ["/bin/bash", "-c"]

    command = join(" ", [
      "./criar_vm.sh",
      each.value.nome,
      tostring(each.value.ram),
      tostring(each.value.disco_mb),
      tostring(each.value.porta_ssh),
      tostring(each.value.porta_app),
      abspath("${path.module}/${each.value.seed}")
    ])
  }
}

output "maquinas" {
  value = {
    for k, vm in local.maquinas :
    k => {
      nome      = vm.nome
      ssh_porta = vm.porta_ssh
      app_porta = vm.porta_app
    }
  }
}
