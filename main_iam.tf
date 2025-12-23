resource "yandex_iam_service_account" "ig_sa" {
  name = "vet-ig-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "ig_sa_editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "ig_sa_vpc_user" {
  folder_id = var.folder_id
  role      = "vpc.user"
  member    = "serviceAccount:${yandex_iam_service_account.ig_sa.id}"
}

resource "time_sleep" "wait_for_ig_sa_permissions" {
  create_duration = "30s"
  depends_on = [
    yandex_resourcemanager_folder_iam_member.ig_sa_editor,
    yandex_resourcemanager_folder_iam_member.ig_sa_vpc_user
  ]
}