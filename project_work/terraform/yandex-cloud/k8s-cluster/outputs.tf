output "master_version" {
  value = var.master_version
}

output "k8s-cluster-id" {
  value = yandex_kubernetes_cluster.k8s-regional.id
}
