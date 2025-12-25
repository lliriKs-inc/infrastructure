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
        external_ipv4_address {
        }
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

resource "yandex_alb_http_router" "router" {
  name = "vet-router"
}

resource "yandex_alb_virtual_host" "vhost" {
  name           = "vet-vhost"
  http_router_id = yandex_alb_http_router.router.id

  route {
    name = "default-route"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.backend.id
        timeout          = "60s"
      }
    }
  }
}

resource "yandex_alb_backend_group" "backend" {
  name = "vet-backend"

  http_backend {
    name             = "app-backend"
    weight           = 1
    port             = 8084
    target_group_ids = [yandex_compute_instance_group.ig.application_load_balancer[0].target_group_id]

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      timeout             = "10s"
      interval            = "15s"
      healthy_threshold   = 2
      unhealthy_threshold = 3

      http_healthcheck {
        path = "/health"
      }
    }
  }
}

output "alb_external_ip" {
  value       = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
  description = "External IP address of Application Load Balancer"
}
