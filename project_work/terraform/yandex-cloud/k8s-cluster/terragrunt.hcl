# stage/k8s/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"

  # Тестовые переменные для запуска terragrunt plan
  mock_outputs = {
    network-main-id = "temporary-network-id"
    k8s_masters_subnet_info = [
      {
        subnet_id = "temporary-masters-id-a"
        zone = "ru-central1-a"
      },
      {
        subnet_id = "temporary-masters-id-b"
        zone = "ru-central1-b"
      },
      {
        subnet_id = "temporary-masters-id-c"
        zone = "ru-central1-d"
      },
    ]
    k8s_workers_subnet_info = [
      {
        subnet_id = "temporary-workers-id-a"
        zone = "ru-central1-a"
      },
      {
        subnet_id = "temporary-workers-id-b"
        zone = "ru-central1-b"
      },
      {
        subnet_id = "temporary-workers-id-d"
        zone = "ru-central1-d"
      },
    ]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

dependency "routing_and_acl" {
  config_path = "../routing_and_acl"

  # Тестовые переменные для запуска terragrunt plan
  mock_outputs = {
    sg_internal-id = "temporary-sg_internal-id"
    sg_k8s_master-id = "temporary-sg_masters-id"
    sg_k8s_worker-id = "temporary-sg_workers-id"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  network-main-id = dependency.network.outputs.network-main-id
  k8s_masters_subnet_info = dependency.network.outputs.k8s_masters_subnet_info
  k8s_workers_subnet_info = dependency.network.outputs.k8s_workers_subnet_info
  sg_internal-id = dependency.routing_and_acl.outputs.sg_internal-id
  sg_k8s_master-id = dependency.routing_and_acl.outputs.sg_k8s_master-id
  sg_k8s_worker-id = dependency.routing_and_acl.outputs.sg_k8s_worker-id
}
