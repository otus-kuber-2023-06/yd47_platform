output "network-main-id" {
  value = yandex_vpc_network.network-main.id
}

output "k8s_masters_subnet_info" {
  value = [for k, v in var.subnets["k8s_masters"] : zipmap(["subnet_id", "zone"], [yandex_vpc_subnet.subnet-main[v.name].id, yandex_vpc_subnet.subnet-main[v.name].zone])]
}

output "k8s_workers_subnet_info" {
  value = [for k, v in var.subnets["k8s_workers"] : zipmap(["subnet_id", "zone"], [yandex_vpc_subnet.subnet-main[v.name].id, yandex_vpc_subnet.subnet-main[v.name].zone])]
}

output "subnets_cidr" {
  value = flatten([for v in concat(var.subnets["k8s_masters"], var.subnets["k8s_workers"]) : v.cidr])
}
