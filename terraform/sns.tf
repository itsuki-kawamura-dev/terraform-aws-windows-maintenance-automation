resource "aws_sns_topic" "maintenance" {
  name = "windows-maintenance-notifications"

  tags = {
    Project = "windows-maintenance-automation"
  }
}

output "sns_topic_arn" {
  description = "SNS topic ARN for maintenance notifications"
  value       = aws_sns_topic.maintenance.arn
}