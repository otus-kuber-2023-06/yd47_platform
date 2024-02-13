variable "network-main-id" {
  description = "The id of main network"
  type        = string
}

variable "subnets_cidr" {
  description = "List of subnets"
  type        = list(string)
}
