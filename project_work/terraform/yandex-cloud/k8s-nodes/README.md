# Создание нод в кластере

## Описание
Модуль для создания [групп узлов](https://cloud.yandex.ru/ru/docs/managed-kubernetes/quickstart#node-group-create) в кластере 

## Структура 

### s_variables.tf 
 Используется для объявления переменных:
 - node_groups - параметры групп узлов: CPU, RAM, Disk, количество узлов в группе; 

### i_variables
 Используется для объявления переменных, импортированных из другого модуля:
 - k8s_workers_subnet_info - список словарей с информацией о подсетях воркер нод, пример см. в `./terragrunt.hcl`;
 - sg_internal-id - ID группы доступа internal;
 - sg_k8s_worker-id - ID группы доступа k8s_worker;
 - master_version - версия kubernetes в кластере;
 - k8s-cluster-id - ID кластера;

### terraform.tvfars
 Используется для определения значений переменных
 
### outputs.tf
 Используется для экспорта фактов о ресурсах созданных в YC, для переиспользования в других модулях.

### node_group.tf
 Используется для определения групп узлов в кластере
 - yandex_kubernetes_node_group - группа узлов с именем `my_node_groups`;
 Все переменные используемые при создании ресурса yandex_kubernetes_node_group описаны в текущем README, а так же в модулях, от которого зависит модуль. Подробную документацию см. [в источнике](https://cloud.yandex.ru/ru/docs/managed-kubernetes/operations/node-group/node-group-create)

## Зависимости модуля 
 Модуль зависит от модулей:
 - network
 - routing_and_acl
 - k8s-cluster
