########################################################################################################################
### Common
########################################################################################################################

variable "environment" {
  type        = string
  nullable    = false
  description = "The environment name being deployed to."
}

########################################################################################################################
### Internal Load Balancer
########################################################################################################################

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "ipv4_primary_cidr_block" {
  type        = string
  description = "The IPV4 CIDR Block of the VPC."
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "The private subnet ids of the VPC."
}

variable "api_health_check_path" {
  type        = string
  default     = "/health"
  description = "The path of the health check endpoint on your API server."
}

variable "api_prefix" {
  type        = string
  default     = "api"
  description = "The prefix of the domain being used in the account. Defaults to api (i.e. api.your-domain.com)"
}

variable "domain" {
  type        = string
  nullable    = false
  description = "The main domain being used in the account. Will be prefixed with api_prefix to control API traffic."
}

variable "acm_certificate_arn" {
  type        = string
  nullable    = false
  description = "The ACM Cert ARN for the main domain."
}

variable "secure_token" {
  type        = string
  default     = ""
  nullable    = true
  description = "The secure token to set to ensure only Cloudfront is used when public traffic trickles down to the Internal LB. Should set with a initially, then changed to an empty string and controlled via the parameter store."
}

########################################################################################################################
### Cloudfront and WAF
########################################################################################################################

variable "allowed_country_codes" {
  type        = list(string)
  default     = ["US"]
  description = "The country codes to allow traffic from."
}

variable "ip_rate_limit" {
  type        = number
  default     = 1000
  description = "The amount of requests to allow from an individual IP over 5 minutes before blocking."
}

variable "hosted_zone_id" {
  type        = string
  nullable    = false
  description = "The ID of the Hosted Zone to use for routing."
}