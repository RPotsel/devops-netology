# https://cloud.yandex.ru/docs/tutorials/web/application-load-balancer-website
# https://cloud.yandex.ru/docs/application-load-balancer

resource "yandex_alb_backend_group" "alb-bg" {
  name                     = "alb-bg"

  http_backend {
    name                   = "backend-1"
    port                   = 80
    target_group_ids       = [yandex_compute_instance_group.alb-vm-group.application_load_balancer.0.target_group_id]
    healthcheck {
      timeout              = "10s"
      interval             = "2s"
      healthcheck_port     = 80
      http_healthcheck {
        path               = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "alb-router" {
  name   = "alb-router"
}

resource "yandex_alb_virtual_host" "alb-host" {
  name           = "alb-host"
  http_router_id = yandex_alb_http_router.alb-router.id
#   authority      = ["alb-example.com"]
  route {
    name = "route-1"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.alb-bg.id
      }
    }
  }
}

resource "yandex_alb_load_balancer" "alb-1" {
  name               = "alb-1"
  network_id         = yandex_vpc_network.network-15-2.id
  security_group_ids = [yandex_vpc_security_group.alb-sg.id]

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.subnet-1.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.subnet-2.id
    }
  }

  listener {
    name = "alb-listener"
    endpoint {
      address {
        external_ipv4_address {
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.alb-router.id
      }
    }
  }
}
