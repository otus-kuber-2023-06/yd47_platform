locals {
  worker_subnet_list = zipmap([for subnet in var.k8s_workers_subnet_info : subnet.zone], [for subnet in var.k8s_workers_subnet_info : subnet.subnet_id])
}
