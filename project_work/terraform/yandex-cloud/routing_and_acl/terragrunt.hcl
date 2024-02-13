# stage/k8s/terragrunt.hcl
include "root" {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"

  # Тестовые переменные для запуска terragrunt plan
  mock_outputs = {
    network-main-id = "temporary-network-id"
    subnets_cidr = [
      "10.0.1.0/28",
      "10.0.2.0/28"
    ]
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate"]
}

inputs = {
  network-main-id = dependency.network.outputs.network-main-id
  subnets_cidr = dependency.network.outputs.subnets_cidr
}
