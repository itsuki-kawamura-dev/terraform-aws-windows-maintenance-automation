output "windows_instance_id" {
  description = "Windows EC2 instance ID"
  value       = aws_instance.windows.id
}

output "windows_private_ip" {
  description = "Private IP address of the Windows EC2 instance"
  value       = aws_instance.windows.private_ip
}

output "windows_ami_id" {
  description = "Windows Server AMI used by the instance"
  value       = nonsensitive(data.aws_ssm_parameter.windows_ami.value)
}