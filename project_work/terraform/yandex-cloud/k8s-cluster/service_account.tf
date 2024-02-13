#=========== service_account ==============
resource "yandex_iam_service_account" "sa-k8s-master" {
  name        = var.sa_k8s-master_name
  description = "K8S regional master service account"
}


#=========== role binding ==============
resource "yandex_resourcemanager_folder_iam_binding" "agent" {
  # Сервисному аккаунту назначается роль "k8s.clusters.agent".
  folder_id = var.folder_id
  role      = "k8s.clusters.agent"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s-master.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "publicAdmin" {
  # Сервисному аккаунту назначается роль "publicAdmin".
  folder_id = var.folder_id
  role      = "vpc.publicAdmin"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s-master.id}"
  ]
}

resource "yandex_resourcemanager_folder_iam_binding" "images-puller" {
  # Сервисному аккаунту назначается роль "container-registry.images.puller".
  folder_id = var.folder_id
  role      = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s-master.id}"
  ]
}


#=========== kms-key ==============
resource "yandex_kms_symmetric_key" "kms-key" {
  # Ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи.
  name              = var.kms_provider_key_name
  default_algorithm = "AES_128"
  rotation_period   = "8760h" # 1 год.
}

resource "yandex_kms_symmetric_key_iam_binding" "viewer" {
  symmetric_key_id = yandex_kms_symmetric_key.kms-key.id
  role             = "kms.viewer"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s-master.id}",
  ]
}
