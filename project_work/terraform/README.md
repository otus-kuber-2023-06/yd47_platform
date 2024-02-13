# terragrunt wrapper for terraform

## Проект для управления виртуализацией связкой Gitlab + Terragrunt (Terraform)

В процессе знакомства с Terraform появилось ощущение, что Terraform имеет проблемы с масштабированием и переиспользованием кода. Terragrunt - обёртка, которая решает эти проблемы.

[terragrunt: quick-start](https://terragrunt.gruntwork.io/docs/getting-started/quick-start/#introduction)

## Перед началом работы

На момент запуска terragrunt должны быть созданы:
 - [Рабочий каталог](https://cloud.yandex.ru/ru/docs/resource-manager/operations/folder/create);
 - OAuth token [полученный в yandex cloud](https://cloud.yandex.ru/ru/docs/iam/concepts/authorization/oauth-token);
 - [s3 хранилище](https://cloud.yandex.ru/ru/docs/storage/operations/buckets/create), для которого требуется [сервисный аккаунт и ключ доступа](https://cloud.yandex.ru/ru/docs/tutorials/infrastructure-management/terraform-state-storage#create-service-account)

## Зависимости

Описываются в `<module-name>/terragrunt.hcl`. 

### Пример 

В модуле routing_and_acl выполняется импорт значения переменной yandex_vpc_subnet из модуля networks.

В файле `routing_and_acl/i_variables.tf` модуля объявляется переменая:

```
variable "network-main-id" {
  description = "The id of main network"
  type        = string
}
```

В файле `routing_and_acl/terragrunt.hcl` описан импорт:

```
dependency "network" {
  config_path = "../network"
}

inputs = {
  yandex_vpc_subnet = dependency.network.outputs.yandex_vpc_subnet
}
```

В модуле network задан сооветствующий output в файле `network/outputs.tf`:

```
output "network_id" {
  value = yandex_vpc_network.network-main.id
}
```

Note that each dependency is automatically considered a dependency in Terragrunt. This means that when you run run-all apply on a config that has dependency blocks, Terragrunt will not attempt to deploy the config until all the modules referenced in dependency blocks have been applied. 

### Зависимости между модулями

#### routing_and_acl зависит от:
 - network

#### k8s-cluster зависит от:
 - network
 - routing_and_acl

#### k8s-nodes зависит от:
 - network
 - routing_and_acl
 - k8s-cluster

## Структура к которой нужно стремиться

```
├── prod
│   ├── app
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── mysql
│   │   ├── main.tf
│   │   └── outputs.tf
│   └── vpc
│       ├── main.tf
│       └── outputs.tf
└── stage
    ├── app
    │   ├── main.tf
    │   └── outputs.tf
    ├── mysql
    │   ├── main.tf
    │   └── outputs.tf
    └── vpc
        ├── main.tf
        └── outputs.tf
```

## Соглашение об именах

### Сгенерированные файлы
 - `g_<name>.tfvars` - файл в котором объявляются переменные;
 - `g_<name>.tf` - файл с конфигурацией или значениями переменных;

### Статические файлы
 - `s_<name>.tfvars` - файл с переменными модуля;
 - `i_<name>.tf` - файл в котором объявляются импортированные из другого модуля переменные;

## Локальная разработка

Для локальной разработки необходимо:
 - OAuth token [полученный в yandex cloud](https://cloud.yandex.ru/ru/docs/iam/concepts/authorization/oauth-token);
 - IAM token [полученный в yandex cloud](https://cloud.yandex.ru/ru/docs/iam/operations/iam-token/create#cli_1);

Раскомментировать в terragrunt.hcl конфигурацию представленную ниже:

#### #=========== main ==============

```
# remote_state {
#   backend = "local"
#   generate = {
#     path = "g_backend.tf"
#     if_exists = "overwrite"
#   }
#   config = {
#   }
# }
```

#### =========== provider ==========

Здесь нужно указать свой IAM токен:

```
provider "yandex" {
  token = "<YOUR IAM TOKEN>"
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone = var.default_zone
}
```

И удалить блок:

```
backend "s3" {
  }
```

## Полезные ссылки
- [Справочник ресурсов](https://cloud.yandex.ru/ru/docs/vpc/tf-ref)
