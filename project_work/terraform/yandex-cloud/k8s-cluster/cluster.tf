resource "yandex_kubernetes_cluster" "k8s-regional" {
  name                    = var.cluster_name
  network_id              = var.network-main-id
  network_policy_provider = var.network_policy_provider
  service_account_id      = yandex_iam_service_account.sa-k8s-master.id
  node_service_account_id = yandex_iam_service_account.sa-k8s-master.id
  master {
    version   = var.master_version
    public_ip = var.master_public_ip
    regional {
      region = var.master_region
      dynamic "location" {
        for_each = var.k8s_masters_subnet_info
        content {
          zone      = location.value["zone"]
          subnet_id = location.value["subnet_id"]
        }
      }
    }
    security_group_ids = [var.sg_internal-id, var.sg_k8s_master-id]
  }  
  kms_provider {
    key_id = yandex_kms_symmetric_key.kms-key.id
  }
  depends_on = [
    yandex_resourcemanager_folder_iam_binding.agent,
    yandex_resourcemanager_folder_iam_binding.publicAdmin,
    yandex_resourcemanager_folder_iam_binding.images-puller
  ]
}
