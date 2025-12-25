resource "yandex_compute_instance" "postgres_vm" {
  name        = "postgres-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.subnet_a.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.postgres_sg.id]
  }

  metadata = {
    user-data = templatefile("${path.module}/postgres-init.yaml", {
      db_password = var.db_password
    })

    ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
  }

  scheduling_policy {
    preemptible = false
  }

  labels = {
    role = "database"
    app  = "vet-clinic"
  }
}

output "postgres_internal_ip" {
  value       = yandex_compute_instance.postgres_vm.network_interface[0].ip_address
  description = "Internal IP address of PostgreSQL VM"
}

output "postgres_vm_id" {
  value       = yandex_compute_instance.postgres_vm.id
  description = "ID of PostgreSQL VM"
}
