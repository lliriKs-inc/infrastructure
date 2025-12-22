output "alb_public_ip" {
  value = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "alb_url_root" {
  value = "http://${yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}/"
}

output "alb_url_health" {
  value = "http://${yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}${var.health_path}"
}
