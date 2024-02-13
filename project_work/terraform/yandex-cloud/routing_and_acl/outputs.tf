output "sg_internal-id" {
  value = yandex_vpc_security_group.internal.id
}

output "sg_k8s_master-id" {
  value = yandex_vpc_security_group.k8s_master.id
}

output "sg_k8s_worker-id" {
  value = yandex_vpc_security_group.k8s_worker.id
}
