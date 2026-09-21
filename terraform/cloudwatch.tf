resource "aws_cloudwatch_log_group" "windows_maintenance" {
  name              = "/aws/ssm/windows-maintenance"
  retention_in_days = 30

  tags = {
    Project = "windows-maintenance-automation"
  }
}
