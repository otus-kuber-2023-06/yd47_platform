# Создания кластера

## Описание
Модуль для создания ресурса [кластер Managed Service for Kubernetes](https://cloud.yandex.ru/ru/docs/managed-kubernetes/quickstart#kubernetes-cluster-create)

## Структура 

### s_variables.tf 
 Используется для объявления переменных:
 - service_account_name - [сервисный аккаунт](https://cloud.yandex.ru/ru/docs/iam/concepts/users/service-accounts);
 - kms_provider_key_name - ключ для шифрования важной информации, такой как пароли, OAuth-токены и SSH-ключи;
 - cluster_name - имя кластера;
 - network_policy_provider - [CNI](https://start.nau.im/x/1IBQBg) для кластера;
 - master_version - версия kubernetes;
 - master_public_ip - bool value. When true, Kubernetes master will have a visible ipv4 address;
 - master_region - географическое расположение, в котором разворачиваются ВМ; 

### i_variables
 Используется для объявления переменных, импортированных из другого модуля:
 - network-main-id - ID сети в yandex cloud;
 - k8s_masters_subnet_info - список словарей с информацией о подсетях мастер нод, пример см. в `./terragrunt.hcl`;
 - k8s_workers_subnet_info - тоже самое для воркер нод;
 - sg_internal-id - ID группы доступа internal;
 - sg_k8s_master-id - ID группы доступа k8s_master;
 - sg_k8s_worker-id - ID группы доступа k8s_worker;

### terraform.tvfars
 Используется для определения значений переменных

### service_account.tf
 Используется для создания сервисного аккаунта и привязки ролей доступа:
 - yandex_iam_service_account - сервисный аккаунт `sa-k8s-master`;
 - yandex_resourcemanager_folder_iam_binding привязка ролей к сервисному аккаунту и каталогу `folder_id`:
     - folder_id (src. ./g_common.tfvars) - каталог в YC;
     - [k8s.clusters.agent](https://cloud.yandex.ru/ru/docs/managed-kubernetes/security/#k8s-clusters-agent)
     - [vpc.publicAdmin](https://cloud.yandex.ru/ru/docs/iam/concepts/access-control/roles#vpc-public-admin)
     - [container-registry.images.puller](https://cloud.yandex.ru/ru/docs/iam/concepts/access-control/roles#cr-images-puller)
 - yandex_kms_symmetric_key - ключ шифрования `kms-key`;
 - yandex_kms_symmetric_key_iam_binding привязка ролей к сервисному аккаунту и ключу `kms-key`:
     - [kms.viewer](https://cloud.yandex.ru/ru/docs/iam/concepts/access-control/roles#kms-viewer)

 :exclamation: при создании ресурса `yandex_resourcemanager_folder_iam_binding` не удалось использовать переменную `sa_k8s-master_name` вместо её значения `sa-k8s-master`:

 ```
   members = [
    "serviceAccount:${yandex_iam_service_account.sa-k8s-master.id}"
  ]
 ```

 terraform не смог выполнить интерполяцию переменных;

### cluster.tf
 Используется для создания кластера
 - yandex_kubernetes_cluster - кластер с именем `k8s-regional`;
 Все переменные используемые при создании ресурса yandex_kubernetes_cluster описаны в текущем README, а так же в модулях, от которого зависит модуль. Подробную документацию см. [в источнике](https://cloud.yandex.ru/ru/docs/managed-kubernetes/operations/kubernetes-cluster/kubernetes-cluster-create)

 :exclamation: так же не удалось использовать:
 - переменную `sa_k8s-master_name` вместо её значения `sa-k8s-master`;
 - переменную `kms_provider_key_name` вместо её значения `kms-key`;

### outputs.tf
Используется для экспорта фактов о ресурсах созданных в YC, для переиспользования в других модулях. 

## Зависимости модуля 
 Модуль зависит от модулей:
 - network
 - routing_and_acl
