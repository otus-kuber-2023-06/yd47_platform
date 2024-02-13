#=========== network ==============
variable "network_name" {
  description = "The name of main network"
  type        = string
}

#=========== subnet ==============
variable "subnets" {
  description = "Subnets for k8s"

  type = map(list(object(
    {
      name = string,
      zone = string,
      cidr = list(string)
    }))
  )
}

#=========== external_ip ==============
variable "external_static_ips" {
  description = "static ips"

  type = map(list(object(
    {
      name = string,
      zone = string
    }))
  )
}
