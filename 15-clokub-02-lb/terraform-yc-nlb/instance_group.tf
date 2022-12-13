# https://cloud.yandex.ru/docs/compute/operations/instance-groups/create-with-balancer
data "yandex_compute_image" "img_nlb_lamp" {
  family = "lamp"
}

resource "yandex_compute_instance_group" "ig-1" {
  name               = "fixed-ig-with-balancer"
  folder_id          = var.yandex_folder_id
  service_account_id = "${yandex_iam_service_account.ig-sa.id}"
  instance_template {
    platform_id = "standard-v3"
    resources {
      memory = 1
      cores  = 2
      core_fraction = 20
    }

    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.img_nlb_lamp.id
        type     = "network-hdd"
        size     = 20
      }
    }

    network_interface {
      network_id = yandex_vpc_network.net_15_1.id
      subnet_ids = [yandex_vpc_subnet.private.id]
      nat        = false
      ipv6       = false
    }

    # https://cloud.yandex.ru/docs/compute/concepts/vm-metadata
    # https://cloud.yandex.ru/docs/storage/concepts/object#object-url
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = <<-EOF
        #!/bin/bash
        echo "<html><p>Netwrok Load Balancer on "`hostname`"</p><img src="https://storage.yandexcloud.net/${yandex_storage_bucket.netology_15_2.bucket}/${yandex_storage_object.devops_png.key}"></html>" > /var/www/html/index.html
      EOF
    }
  }

  # https://cloud.yandex.ru/docs/compute/operations/vm-create/create-preemptible-vm
  # https://github.com/yandex-cloud/docs/blob/master/ru/compute/operations/vm-create/create-preemptible-vm.md
  # scheduling_policy {
  #   preemptible = true
  # }

  # https://cloud.yandex.ru/docs/compute/concepts/instance-groups/policies/scale-policy
  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  # https://cloud.yandex.ru/docs/compute/concepts/instance-groups/policies/deploy-policy
  deploy_policy {
    max_creating     = 3
    max_deleting     = 3
    max_unavailable  = 1
    max_expansion    = 0
    # startup_duration = 10
  }

  load_balancer {
    target_group_name        = "target-group"
    target_group_description = "load balancer target group"
  }
}
