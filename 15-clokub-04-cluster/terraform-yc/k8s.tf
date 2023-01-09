# https://cloud.yandex.ru/docs/managed-kubernetes/operations/kubernetes-cluster/kubernetes-cluster-create
# https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster
resource "yandex_kubernetes_cluster" "k8s-regional" {
  name        = "k8s-cluster-hw154"
  description = "Netology homework k8s cluster"
  network_id = yandex_vpc_network.network-15-4.id

  master {
    version = "1.22"
    public_ip = true

    security_group_ids = [yandex_vpc_security_group.k8s-main-sg.id]

    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.k8s-subnet-a.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet-a.id
      }
      location {
        zone      = yandex_vpc_subnet.k8s-subnet-b.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet-b.id
      }
      location {
        zone      = yandex_vpc_subnet.k8s-subnet-c.zone
        subnet_id = yandex_vpc_subnet.k8s-subnet-c.id
      }
    }
    # zonal {
    #   zone      = yandex_vpc_subnet.k8s-subnet-a.zone
    #   subnet_id = yandex_vpc_subnet.k8s-subnet-a.id
    # }

    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        day        = "monday"
        start_time = "15:00"
        duration   = "3h"
      }
      maintenance_window {
        day        = "friday"
        start_time = "10:00"
        duration   = "4h30m"
      }
    }
  }

  service_account_id      = yandex_iam_service_account.k8s-agent.id # Cluster service account ID.
  node_service_account_id = yandex_iam_service_account.k8s-agent.id # Node group service account ID.

  kms_provider {
    key_id = yandex_kms_symmetric_key.key-n154.id
  }

  release_channel = "STABLE"

  depends_on = [
    yandex_resourcemanager_folder_iam_binding.k8s-clusters-agent,
    yandex_resourcemanager_folder_iam_binding.vpc-public-admin,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}

# https://cloud.yandex.ru/docs/managed-kubernetes/operations/node-group/node-group-create
# https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group
resource "yandex_kubernetes_node_group" "k8s-node-group" {
  description = "Node group for the Managed Service for Kubernetes cluster"
  name        = "k8s-node-group-hw154"
  cluster_id  = yandex_kubernetes_cluster.k8s-regional.id
  version     = "1.22"

  scale_policy {
    auto_scale {
      initial = 1
      min = 1
      max = 6
    }
  }

  instance_template {
    name = "test-{instance.short_id}-{instance_group.id}"
    platform_id = "standard-v2" # Intel Cascade Lake

    container_runtime {
      type = "containerd"
    }

    network_interface {
      nat = true
      subnet_ids         = [
        yandex_vpc_subnet.k8s-subnet-a.id,
        # allocation_policy.locations: auto scale node groups can have only one location
        # yandex_vpc_subnet.k8s-subnet-b.id
      ]
      security_group_ids = [yandex_vpc_security_group.k8s-main-sg.id]
    }
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      type = "network-hdd"
      size = 32
    }
    # key "user-data" won't be provided into instances
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
    scheduling_policy {
      preemptible = false
    }
  }

  # allocation_policy.locations: auto scale node groups can have only one location
  allocation_policy {
    location {
      zone = yandex_vpc_subnet.k8s-subnet-a.zone
    }
    # location {
    #   zone = yandex_vpc_subnet.k8s-subnet-b.zone
    # }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }
    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }
  }
}
