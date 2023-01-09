# https://cloud.yandex.ru/docs/iam/
# https://cloud.yandex.ru/docs/managed-mysql/security/

resource "yandex_iam_service_account" "mysql-admin" {
  name        = "mysql-admin"
  description = "service account to manage mysql"
}

resource "yandex_resourcemanager_folder_iam_binding" "admin" {
  folder_id = var.yandex_folder_id
  role      = "mdb.admin"
  members   = [
    "serviceAccount:${yandex_iam_service_account.mysql-admin.id}",
  ]
}

# https://cloud.yandex.ru/docs/managed-kubernetes/security/

resource "yandex_iam_service_account" "k8s-agent" {
  name        = "k8s-admin"
  description = "K8S regional service account"
}

resource "yandex_resourcemanager_folder_iam_binding" "k8s-clusters-agent" {
  folder_id = var.yandex_folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-agent.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "vpc-public-admin" {
  folder_id = var.yandex_folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-agent.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  folder_id = var.yandex_folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-agent.id}"
  ]
}

# https://cloud.yandex.ru/docs/network-load-balancer/security/
resource "yandex_resourcemanager_folder_iam_binding" "load-balancer-admin" {
  folder_id = var.yandex_folder_id
  role      = "load-balancer.admin"
  members = [
    "serviceAccount:${yandex_iam_service_account.k8s-agent.id}"
  ]
}
