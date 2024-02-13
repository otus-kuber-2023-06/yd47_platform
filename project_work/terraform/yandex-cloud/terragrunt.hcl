# stage/terragrunt.hcl

#=========== main ==============
# Для локальной разработки раскомментировать
#===============================

# remote_state {
#   backend = "local"
#   generate = {
#     path = "g_backend.tf"
#     if_exists = "overwrite"
#   }
#   config = {
#   }
# }


#=========== provider ==========
# Конфигурация provider
# Для локальной разработки закомментировать блок 'backend "s3 {} "'
#===============================

generate "g_provider" {
  path = "g_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_providers {
    yandex = {
      source = "local-registry.com/yandex-cloud/yandex"
      version = "0.105.0"
    }
  }

  backend "s3" {
    bucket = "k8s-managed"

    access_key = "${get_env("AWS_ACCESS_KEY_ID")}"
    secret_key = "${get_env("AWS_SECRET_ACCESS_KEY")}"
    endpoints = {
            s3 = "https://storage.yandexcloud.net"
        }
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region                      = "ru-central1"
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true # необходимая опция при описании бэкенда для Terraform версии 1.6.1 и старше.
    skip_s3_checksum            = true # необходимая опция при описании бэкенда для Terraform версии 1.6.3 и старше.
  }
}

provider "yandex" {
  token = "${get_env("YC_IAM_TOKEN")}"
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  zone = var.default_zone
}
EOF
}


#========== variables ==========
# Генерация файлов с переменными
#===============================

generate "g_variables" {
  path = "g_variables.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
variable "cloud_id" {
  description = "The cloud ID"
  type        = string
}
variable "folder_id" {
  description = "The folder ID"
  type        = string
}
variable "default_zone" {
  description = "The default zone"
  type        = string
  default     = "ru-cenral1-a"
}
EOF
}


#========== values =============
# Генерация значений переменных
#===============================

generate "g_common_vars" {
  path = "g_common.tfvars"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
# Значения из yandex-cloud
cloud_id = "b1g8h7q170mmg4kg9sjd"
folder_id = "b1g2v50d0ub5tj26clup"
default_zone = "ru-central1-a"
EOF
}


#========= extra-vars ==========
# Параметры запуска terraform
#===============================

# Запуск terraform модуля с указанием файла переменных
terraform {
  extra_arguments "common_vars" {
    commands = ["apply", "destroy", "plan"]

    arguments = [
      "-var-file=g_common.tfvars"
    ]
  }
}
