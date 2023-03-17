output "alb_security_group_id" {
    value = aws_security_group.alb_security_group.id
}

output "psi_security_group_id" {
    value = aws_security_group.psi_security_group.id
}