output "instance_id" {
    description = "D of EC2 instance"
    value       = aws_instance.cricket.id
}