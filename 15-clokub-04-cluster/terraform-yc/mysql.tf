resource "yandex_mdb_mysql_cluster" "my-mysql" {
  name                = "my-mysql"
  environment         = "PRESTABLE"
  network_id          = yandex_vpc_network.network-15-4.id
  version             = "8.0"
  security_group_ids  = [ yandex_vpc_security_group.mysql-sg.id ]
  deletion_protection = true

  # https://cloud.yandex.ru/docs/managed-mysql/concepts/instance-types
  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-hdd"
    disk_size          = 20
  }

  host {
    name      = "na-1"
    zone      = yandex_vpc_subnet.subnet-1.zone
    subnet_id = yandex_vpc_subnet.subnet-1.id
    #assign_public_ip = true
  }

  host {
    name      = "na-2"
    zone      = yandex_vpc_subnet.subnet-2.zone
    subnet_id = yandex_vpc_subnet.subnet-2.id
  }

  # https://cloud.yandex.ru/docs/managed-mysql/concepts/settings-list
  mysql_config = {
    sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
    max_connections               = 100
    default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"
    innodb_print_all_deadlocks    = true
  }

  # https://cloud.yandex.ru/docs/managed-mysql/operations/cluster-backups
  backup_window_start {
    hours = 23
    minutes = 59
  }

  # https://cloud.yandex.ru/docs/managed-mysql/api-ref/grpc/cluster_service#MaintenanceWindow
  maintenance_window {
    type = "ANYTIME"
  }
}

resource "yandex_mdb_mysql_database" "netology_db" {
  cluster_id = yandex_mdb_mysql_cluster.my-mysql.id
  name       = "netology_db"
}

# https://registry.tfpla.net/providers/yandex-cloud/yandex/latest/docs/resources/mdb_mysql_user
resource "yandex_mdb_mysql_user" "netology" {
  cluster_id = yandex_mdb_mysql_cluster.my-mysql.id
  name       = "netology"
  password   = "password"
 
  permission {
    database_name = yandex_mdb_mysql_database.netology_db.name
    roles         = ["ALL"]
  }

  connection_limits {
    max_questions_per_hour   = 100
    max_updates_per_hour     = 100
    max_connections_per_hour = 100
    max_user_connections     = 100
  }

  global_permissions = ["PROCESS"]
  authentication_plugin = "SHA256_PASSWORD"
}
