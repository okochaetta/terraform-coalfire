output "public_ip" {
  value = module.bastian.public_ip
}

output "ssh_command" {
  value = "ssh -i ${local_file.this.filename} ec2-user@${module.bastian.public_ip}"
}

output "alb_dns_name" {
  value = module.web.alb_dns_name
}
