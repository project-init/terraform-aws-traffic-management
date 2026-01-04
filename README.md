# Project Init AWS Traffic Management

Module used to set up your internal load balancer, Cloudfront and a WAF.

## Quick Start

1. `mise format`
2. `mise docs`

## Usage

Check our [Examples](examples) for full usage information.

## Useful Docs

* [Code of Conduct](./CODE_OF_CONDUCT.md)
* [Contribution Guide](./CONTRIBUTING.md)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.81.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.internal_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_cloudfront_distribution.alb_distribution](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudfront_vpc_origin.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_vpc_origin) | resource |
| [aws_lb_listener.http](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener.https_prelive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_listener_rule.api_prelive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_lb_target_group.api](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_lb_target_group.api_prelive](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group) | resource |
| [aws_route53_record.domain](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_security_group.internal_load_balancer](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.internal_load_balancer_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.internal_load_balancer_http_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.internal_load_balancer_https_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.internal_load_balancer_https_ingress_cloudfront](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.internal_load_balancer_https_prelive_ingress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ssm_parameter.secure_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_wafv2_web_acl.waf](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_ec2_managed_prefix_list.cloudfront_prefix_list](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ec2_managed_prefix_list) | data source |
| [aws_ssm_parameter.secure_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acm_certificate_arn"></a> [acm\_certificate\_arn](#input\_acm\_certificate\_arn) | The ACM Cert ARN for the main domain. | `string` | n/a | yes |
| <a name="input_allowed_country_codes"></a> [allowed\_country\_codes](#input\_allowed\_country\_codes) | The country codes to allow traffic from. | `list(string)` | <pre>[<br/>  "US"<br/>]</pre> | no |
| <a name="input_api_health_check_path"></a> [api\_health\_check\_path](#input\_api\_health\_check\_path) | The path of the health check endpoint on your API server. | `string` | `"/health"` | no |
| <a name="input_api_prefix"></a> [api\_prefix](#input\_api\_prefix) | The prefix of the domain being used in the account. Defaults to api (i.e. api.your-domain.com) | `string` | `"api"` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The main domain being used in the account. Will be prefixed with api\_prefix to control API traffic. | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The environment name being deployed to. | `string` | n/a | yes |
| <a name="input_hosted_zone_id"></a> [hosted\_zone\_id](#input\_hosted\_zone\_id) | The ID of the Hosted Zone to use for routing. | `string` | n/a | yes |
| <a name="input_ip_rate_limit"></a> [ip\_rate\_limit](#input\_ip\_rate\_limit) | The amount of requests to allow from an individual IP over 5 minutes before blocking. | `number` | `1000` | no |
| <a name="input_ipv4_primary_cidr_block"></a> [ipv4\_primary\_cidr\_block](#input\_ipv4\_primary\_cidr\_block) | The IPV4 CIDR Block of the VPC. | `string` | n/a | yes |
| <a name="input_private_subnet_ids"></a> [private\_subnet\_ids](#input\_private\_subnet\_ids) | The private subnet ids of the VPC. | `list(string)` | n/a | yes |
| <a name="input_secure_token"></a> [secure\_token](#input\_secure\_token) | The secure token to set to ensure only Cloudfront is used when public traffic trickles down to the Internal LB. Should set with a initially, then changed to an empty string and controlled via the parameter store. | `string` | `""` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the VPC. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_prelive_target_group_arn"></a> [api\_prelive\_target\_group\_arn](#output\_api\_prelive\_target\_group\_arn) | The ARN for the target group managing the Prelive API service. |
| <a name="output_api_target_group_arn"></a> [api\_target\_group\_arn](#output\_api\_target\_group\_arn) | The ARN for the target group managing the API service. |
| <a name="output_internal_lb_dns_name"></a> [internal\_lb\_dns\_name](#output\_internal\_lb\_dns\_name) | The DNS name of the internal load balancer. |
| <a name="output_internal_lb_https_listener_arn"></a> [internal\_lb\_https\_listener\_arn](#output\_internal\_lb\_https\_listener\_arn) | The HTTPS Listener ARN of the internal load balancer. |
| <a name="output_internal_lb_https_prelive_listener_arn"></a> [internal\_lb\_https\_prelive\_listener\_arn](#output\_internal\_lb\_https\_prelive\_listener\_arn) | The HTTPS Listener ARN of the internal load balancer. |
| <a name="output_internal_lb_name"></a> [internal\_lb\_name](#output\_internal\_lb\_name) | The name of the internal load balancer. |
| <a name="output_internal_lb_security_group_id"></a> [internal\_lb\_security\_group\_id](#output\_internal\_lb\_security\_group\_id) | The Security Group ID of the internal load balancer. |
| <a name="output_internal_lb_zone_id"></a> [internal\_lb\_zone\_id](#output\_internal\_lb\_zone\_id) | The Zone ID of the internal load balancer. |
| <a name="output_wafv2_web_acl_arn"></a> [wafv2\_web\_acl\_arn](#output\_wafv2\_web\_acl\_arn) | The ARN of the WAF. |
<!-- END_TF_DOCS -->