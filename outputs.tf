# Output
output "aws_instance_public_dns" {
  description = "Public url for new AWS instance"
  value       = aws_instance.nginx.public_dns
}

output "aws_instance_public_ip" {
  description = "Public ip for new AWS instance"
  value       = aws_instance.nginx.public_ip
}

output "postgres_instance_endpoint" {
  description = "Public ip for new AWS instance"
  value       = aws_db_instance.postgres.endpoint
}
