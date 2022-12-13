data "yandex_compute_image" "img_nlb_lamp" {
  family = "lamp"
}

resource "yandex_compute_instance_group" "alb-vm-group" {
  name               = "fixed-ig-with-application-balancer"
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
        size     = 5
      }
    }

    network_interface {
      network_id = yandex_vpc_network.network-15-2.id
      subnet_ids = [yandex_vpc_subnet.subnet-1.id, yandex_vpc_subnet.subnet-2.id]
      nat        = false
      ipv6       = false
      security_group_ids = [yandex_vpc_security_group.alb-vm-sg.id]
    }

    # https://cloud.yandex.ru/docs/compute/concepts/vm-metadata
    # https://cloud.yandex.ru/docs/storage/concepts/object#object-url
    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = <<-EOF
        #!/bin/bash
        echo "<html><p>Application Load Balancer on "`hostname`"</p><img src="https://storage.yandexcloud.net/${yandex_storage_bucket.netology_15_2.bucket}/${yandex_storage_object.devops_png.key}"></html>" > /var/www/html/index.html
      EOF
    }
  }

  # https://cloud.yandex.ru/docs/compute/concepts/instance-groups/policies/scale-policy
  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b"]
  }

  # https://cloud.yandex.ru/docs/compute/concepts/instance-groups/policies/deploy-policy
  deploy_policy {
    max_unavailable  = 1
    max_expansion    = 0
  }

  application_load_balancer {
    target_group_name        = "alb-tg"
    target_group_description = "load balancer target group"
  }
}
