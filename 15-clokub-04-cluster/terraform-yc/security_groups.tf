# https://cloud.yandex.ru/docs/vpc/operations/security-group-create

resource "yandex_vpc_security_group" "mysql-sg" {
  name       = "mysql-sg"
  network_id = yandex_vpc_network.network-15-4.id

  ingress {
    description    = "MySQL"
    port           = 3306
    protocol       = "TCP"
    v4_cidr_blocks = [ "0.0.0.0/0" ]
  }
}

resource "yandex_vpc_security_group" "k8s-main-sg" {
  name        = "k8s-main-sg"
  description = "Security group for the Managed Service for Kubernetes cluster and nodes"
  network_id  = yandex_vpc_network.network-15-4.id

  ingress {
    protocol          = "TCP"
    description       = "The rule allows availability checks from the load balancer's range of addresses"
    predefined_target = "loadbalancer_healthchecks" # The load balancer's address range.
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "The rule allows the master-node and node-node interaction within the security group"
    predefined_target = "self_security_group"
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ANY"
    description       = "The rule allows the pod-pod and service-service interaction"
    v4_cidr_blocks    = concat(yandex_vpc_subnet.k8s-subnet-a.v4_cidr_blocks, yandex_vpc_subnet.k8s-subnet-b.v4_cidr_blocks)
    from_port         = 0
    to_port           = 65535
  }
  ingress {
    protocol          = "ICMP"
    description       = "The rule allows receipt of debugging ICMP packets from internal subnets"
    v4_cidr_blocks    = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }
  ingress {
    description    = "The rule allows connection to Kubernetes API on 6443 port from the Internet"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 6443
  }
  ingress {
    description    = "The rule allows connection to Kubernetes API on 443 port from the Internet"
    protocol       = "TCP"
    v4_cidr_blocks = ["0.0.0.0/0"]
    port           = 443
  }
  ingress {
    protocol          = "TCP"
    description       = "The rule allows connection to secify NodePort"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 30000
    to_port           = 32767
  }
  egress {
    protocol          = "ANY"
    description       = "The rule allows all outgoing traffic"
    v4_cidr_blocks    = ["0.0.0.0/0"]
    from_port         = 0
    to_port           = 65535
  }
}
