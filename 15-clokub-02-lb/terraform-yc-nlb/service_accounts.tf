resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "service account to manage compute instance group"
}

resource "yandex_resourcemanager_folder_iam_binding" "editor" {
  folder_id = var.yandex_folder_id
  role      = "editor"
  members   = [
    "serviceAccount:${yandex_iam_service_account.ig-sa.id}",
  ]
}

# resource "yandex_resourcemanager_folder_iam_binding" "viewer" {
#   folder_id = var.yandex_folder_id
#   role      = "viewer"
#   members   = [
#     "serviceAccount:${yandex_iam_service_account.ig-sa.id}",
#   ]
# }

resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.ig-sa.id
  description        = "static access key for object storage"
}
