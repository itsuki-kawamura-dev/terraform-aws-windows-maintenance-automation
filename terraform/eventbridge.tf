resource "aws_iam_role" "eventbridge_scheduler" {
  name = "windows-maintenance-scheduler-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "scheduler.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Project = "windows-maintenance-automation"
  }
}

resource "aws_iam_role_policy" "eventbridge_scheduler" {
  name = "windows-maintenance-scheduler-policy"
  role = aws_iam_role.eventbridge_scheduler.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "states:StartExecution"
      ]

      Resource = aws_sfn_state_machine.maintenance.arn
    }]
  })
}

resource "aws_scheduler_schedule" "windows_maintenance" {
  name        = "windows-maintenance-monthly"
  description = "Runs the automated Windows maintenance workflow monthly"

  schedule_expression          = "cron(0 2 1 * ? *)"
  schedule_expression_timezone = "Europe/London"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = aws_sfn_state_machine.maintenance.arn
    role_arn = aws_iam_role.eventbridge_scheduler.arn
  }
}