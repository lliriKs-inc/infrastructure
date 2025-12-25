# 1. Service Account для S3
resource "yandex_iam_service_account" "storage_sa" {
  name = "vet-storage-sa"
}

# 2. Роль storage.admin
resource "yandex_resourcemanager_folder_iam_member" "storage_admin" {
  folder_id = var.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.storage_sa.id}"
}

#resource "time_sleep" "wait_for_storage_sa_permissions" {
#  create_duration = "30s"
#  depends_on = [
#    yandex_resourcemanager_folder_iam_member.storage_admin
#  ]
#}

# 3. Static Access Key
resource "yandex_iam_service_account_static_access_key" "storage_key" {
  service_account_id = yandex_iam_service_account.storage_sa.id
}

# 4. S3 Bucket
resource "yandex_storage_bucket" "vet_bucket" {
  access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
  secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
  bucket     = "vet-clinic-${var.folder_id}"

  force_destroy = true

  anonymous_access_flags {
    read = true
    list = false
  }

  depends_on = [
    yandex_resourcemanager_folder_iam_member.storage_admin
  ]
}

# 5. Outputs для .NET
output "s3_access_key" {
  value     = yandex_iam_service_account_static_access_key.storage_key.access_key
  sensitive = true
}
output "s3_secret_key" {
  value     = yandex_iam_service_account_static_access_key.storage_key.secret_key
  sensitive = true
}
output "bucket_name" {
  value = yandex_storage_bucket.vet_bucket.bucket
}
