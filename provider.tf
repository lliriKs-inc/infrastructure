provider "yandex" {
  service_account_key_file = "${path.module}/sa-key.json"  # Путь к JSON-ключу
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}
