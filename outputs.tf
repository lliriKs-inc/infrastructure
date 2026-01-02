output "alb_public_ip" {
  value = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
}

output "alb_url_root" {
  value = "http://${yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}/"
}

output "alb_url_health" {
  value = "http://${yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address}${var.health_path}"
}

output "ticket_api_url" {
  value       = "https://${yandex_api_gateway.ticket_api.domain}"
  description = "API Gateway URL for ticket generation"
}

output "ticket_function_id" {
  value       = yandex_function.ticket_generator.id
  description = "Cloud Function ID for ticket generator"
}
