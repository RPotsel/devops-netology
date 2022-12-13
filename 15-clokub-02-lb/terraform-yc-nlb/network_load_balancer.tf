# https://cloud.yandex.ru/docs/network-load-balancer/operations/load-balancer-create
# https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/lb_network_load_balancer

resource "yandex_lb_network_load_balancer" "network_load_balancer" {
  name = "net-lb"
  listener {
    name = "net-lb-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.ig-1.load_balancer.0.target_group_id
    healthcheck {
      name = "http"
        http_options {
          port = 80
          path = "/"
        }
    }
  }
}
