#############################################
################User Management##############
#############################################
output "user_api_url" {
  description = "The URL of the API Gateway"
  value       = "${aws_api_gateway_rest_api.this.execution_arn}/prod"
}