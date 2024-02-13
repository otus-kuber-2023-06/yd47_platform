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

variable "sg_k8s_worker-id" {
  description = "The id of workers security group"
  type        = string
}

variable "master_version" {
  description = "Version of Kubernetes that will be used for master."
  type = string
  default = null
}

variable "k8s-cluster-id" {
  description = "The id of managed cluster"
  type        = string
}
