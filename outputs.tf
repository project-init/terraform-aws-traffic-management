output "internal_lb_name" {
  value       = aws_alb.internal_load_balancer.name
  description = "The name of the internal load balancer."
}

output "internal_lb_dns_name" {
  value       = aws_alb.internal_load_balancer.dns_name
  description = "The DNS name of the internal load balancer."
}

output "internal_lb_zone_id" {
  value       = aws_alb.internal_load_balancer.zone_id
  description = "The Zone ID of the internal load balancer."
}

output "internal_lb_security_group_id" {
  value       = aws_security_group.internal_load_balancer.id
  description = "The Security Group ID of the internal load balancer."
}

output "internal_lb_https_listener_arn" {
  value       = aws_lb_listener.https.arn
  description = "The HTTPS Listener ARN of the internal load balancer."
}

output "internal_lb_https_prelive_listener_arn" {
  value       = aws_lb_listener.https_prelive.arn
  description = "The HTTPS Listener ARN of the internal load balancer."
}

output "api_target_group_arn" {
  value       = aws_lb_target_group.api.arn
  description = "The ARN for the target group managing the API service."
}

output "api_prelive_target_group_arn" {
  value       = aws_lb_target_group.api_prelive.arn
  description = "The ARN for the target group managing the Prelive API service."
}