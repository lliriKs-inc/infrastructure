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
        repo_url = var.repo_url
        s3_access_key      = yandex_iam_service_account_static_access_key.storage_key.access_key
        s3_secret_key      = yandex_iam_service_account_static_access_key.storage_key.secret_key
        s3_bucket_name     = yandex_storage_bucket.vet_bucket.bucket
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

  depends_on = [time_sleep.wait_for_ig_sa_permissions]
}
