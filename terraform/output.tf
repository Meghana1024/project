output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "web1_private_ip" {
  value = aws_instance.web1.private_ip
}

output "web2_private_ip" {
  value = aws_instance.web2.private_ip
}