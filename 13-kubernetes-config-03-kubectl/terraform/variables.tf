# ID YC
variable "yandex_cloud_id" {
  default = "b1gm04d20fit9ltelv1p"
}

# Folder YC
variable "yandex_folder_id" {
  default = "b1gu9vr18o6v8qc41svt"
}

# Control plane VM
variable "control_node" {
  type = map

  default = {
    name      = "control"
    count     = 1
    cores     = 2
    memory    = 2
    disk_size = 50
  }
}

# Worker VM
variable "worker_node" {
  type = map

  default = {
    name      = "worker"
    count     = 2
    cores     = 2
    memory    = 4
    disk_size = 50
  }
}
