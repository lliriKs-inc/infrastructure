# API Gateway для публичного доступа к функции генерации талонов
resource "yandex_api_gateway" "ticket_api" {
  name = "vet-ticket-api"
  
  spec = templatefile("${path.module}/apigw_ticket.yaml.tftpl", {
    function_id        = yandex_function.ticket_generator.id
    service_account_id = yandex_iam_service_account.storage_sa.id
  })

  depends_on = [
    yandex_function.ticket_generator
  ]
}
