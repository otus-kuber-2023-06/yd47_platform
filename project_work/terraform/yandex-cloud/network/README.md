# Конфигурация сети

## Описание
Модуль для создания сетевых ресурсов в облаке. 

## Структура 

### s_variables.tf 
 Используется для объявления переменных:
 - network_name - имя сущности vpc/networks в YC;
 - subnets - описание ресурсов "подсеть";
 - external_static_ips - внешние IP адреса;

### terraform.tvfars
 Используется для определения значений переменных

### locals.tf
 Используется для формирования массива списков подсетей

### vpc.tf
Используется для определения ресурсов network-main (сеть) и subnet-main (подсеть):
- network-main: создаётся сущность vpc/networks в YC и именем network_name;
  переменные:
    - network_name (src. terraform.tvfars) - имя сети;
 
- subnet-main: в сети network-main создаются подсети;
  переменные:
    - subnet_array - (src. locals.tf) - массив списков подсетей;
    - cidr, name, zone (src. terraform.tfvars) - одноименные значения переменных для каждой из подсетей;
 
В цикле выполняется генерация конфигурации ресурсов, пример:
```
resource "yandex_vpc_subnet" "mysubnet-a" {
  v4_cidr_blocks = ["10.5.0.0/16"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-main.id
}
```

### static-ip.tf
Используется для определения ресурса public_addr (внешний ip адрес):
- public_addr: создаётся сущность vpc/addresses в YC;
  переменные:
    - external_ips_array - (src. locals.tf) - массив списков внешних IP адресов;
    - name, zone (src. terraform.tfvars) - одноименные значения переменных для каждого внешнего IP адреса

В цикле выполняется генерация конфигурации ресурсов, пример:
```
resource "yandex_vpc_address" "public_addr" {
  external_ipv4_address {
    address                  = (known after apply)
    zone_id                  = "ru-central1-a"
    }
}
```

### outputs.tf
Используется для экспорта фактов о ресурсах созданных в YC, для переиспользования в других модулях. 

## Зависимости модуля 

