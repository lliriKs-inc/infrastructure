locals {
  alb_ip = yandex_alb_load_balancer.alb.listener[0].endpoint[0].address[0].external_ipv4_address[0].address
  app_url = "http://${local.alb_ip}"
}

resource "yandex_function" "ticket_generator" {
  name               = "vet-ticket-generator"
  user_hash          = "v3"
  runtime            = "python311"
  entrypoint         = "index.handler"
  memory             = 256
  execution_timeout  = "30"
  service_account_id = yandex_iam_service_account.storage_sa.id

  environment = {
    TICKETS_BUCKET          = yandex_storage_bucket.vet_bucket.bucket
    AWS_ACCESS_KEY_ID       = yandex_iam_service_account_static_access_key.storage_key.access_key
    AWS_SECRET_ACCESS_KEY   = yandex_iam_service_account_static_access_key.storage_key.secret_key
    APP_URL                 = local.app_url
    TICKET_INTERNAL_SECRET  = var.ticket_internal_secret
  }

  content {
    zip_filename = "${path.module}/function.zip"
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin,
    yandex_resourcemanager_folder_iam_member.storage_sa_function_invoker,
    yandex_alb_load_balancer.alb
  ]
}
