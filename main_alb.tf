resource "yandex_alb_target_group" "tg" {
  name      = "vet-alb-tg"

  # Берем машины из Instance Group
  dynamic "target" {
    for_each = yandex_compute_instance_group.ig.instances
    content {
      subnet_id  = target.value.network_interface[0].subnet_id
      ip_address = target.value.network_interface[0].ip_address
    }
  }
}

resource "yandex_alb_backend_group" "bg" {
  name = "vet-alb-bg"

  http_backend {
    name             = "vet-backend"
    port             = var.app_port
    # Теперь ссылаемся на РЕСУРС, который выше
    target_group_ids = [yandex_alb_target_group.tg.id]

    healthcheck {
      timeout  = "2s"
      interval = "5s"
      healthy_threshold   = 2
      unhealthy_threshold = 3
      http_healthcheck {
        path = var.health_path
      }
    }
  }

  session_affinity {
    cookie {
      name = "yc-sticky-session" # Имя куки (может быть любым)
      ttl  = "0s"                # 0s = кука живет пока открыт браузер (сессионная)
    }
  }
}

resource "yandex_alb_http_router" "router" {
  name = "vet-alb-router"
}

resource "yandex_alb_virtual_host" "vh" {
  name           = "vet-alb-vh"
  http_router_id = yandex_alb_http_router.router.id

  route {
    name = "route-all"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.bg.id
        timeout          = "10s"
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb" {
  name       = "vet-alb"
  network_id = yandex_vpc_network.net.id

  allocation_policy {
    location {
      zone_id   = var.zone
      subnet_id = yandex_vpc_subnet.subnet_a.id
    }
  }

  listener {
    name = "http-listener"

    endpoint {
      address {
        external_ipv4_address {}
      }

      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.router.id
      }
    }
  }
}
