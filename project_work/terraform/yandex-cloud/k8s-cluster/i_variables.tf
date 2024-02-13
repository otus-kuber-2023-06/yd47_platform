variable "network-main-id" {
  description = "The id of main network"
  type        = string
}

variable "k8s_masters_subnet_info" {
  description = "k8s_masters_subnet_info"

  type = list(object(
    {
      subnet_id = string,
      zone = string
    }))
}

variable "k8s_workers_subnet_info" {
  description = "k8s_workers_subnet_info"

  type = list(object(
    {
      subnet_id = string,
      zone = string
    }))
}

variable "sg_internal-id" {
  description = "The id of internal security group"
  type        = string
}

variable "sg_k8s_master-id" {
  description = "The id of master security group"
  type        = string
}

variable "sg_k8s_worker-id" {
  description = "The id of workers security group"
  type        = string
}
