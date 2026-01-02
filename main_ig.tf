data "yandex_compute_image" "ubuntu" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance_group" "ig" {
  name               = "vet-ig"
  folder_id          = var.folder_id
  service_account_id = yandex_iam_service_account.ig_sa.id

  instance_template {
    platform_id = "standard-v3"

    resources {
      cores  = 2
      memory = 2
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu.id
        size     = 20
        type     = "network-hdd"
      }
    }

    network_interface {
      subnet_ids         = [yandex_vpc_subnet.subnet_a.id]
      nat                = true
      security_group_ids = [yandex_vpc_security_group.sg.id]
    }

    metadata = {
      user-data = templatefile("${path.module}/cloud-init.yaml.tftpl", {

        repo_url         = var.repo_url
        postgres_host    = yandex_compute_instance.postgres_vm.network_interface[0].ip_address
        postgres_password = var.db_password
        s3_access_key    = yandex_iam_service_account_static_access_key.storage_key.access_key
        s3_secret_key    = yandex_iam_service_account_static_access_key.storage_key.secret_key
        s3_bucket_name   = yandex_storage_bucket.vet_bucket.bucket
        ticket_internal_secret = var.ticket_internal_secret
        ticket_api_domain      = yandex_api_gateway.ticket_api.domain
      })


      ssh-keys = "${var.vm_user}:${var.ssh_public_key}"
    }
  }

  scale_policy {
    fixed_scale {
      size = var.ig_size
    }
  }

  allocation_policy {
    zones = [var.zone]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  health_check {
    interval            = 15
    timeout             = 10
    unhealthy_threshold = 3
    healthy_threshold   = 2

    http_options {
      port = 8084
      path = "/health"
    }
  }


  application_load_balancer {
    target_group_name = "vet-tg"
  }

  depends_on = [
    time_sleep.wait_for_ig_sa_permissions,
    yandex_compute_instance.postgres_vm,
    yandex_api_gateway.ticket_api
  ]
}

output "instance_group_id" {
  value       = yandex_compute_instance_group.ig.id
  description = "ID of the Instance Group"
}

output "target_group_id" {
  value       = yandex_compute_instance_group.ig.application_load_balancer[0].target_group_id
  description = "ID of the Target Group for ALB"
}

