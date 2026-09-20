resource "aws_iam_role" "step_functions" {
  name = "windows-maintenance-step-functions-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "states.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "windows-maintenance-automation"
  }
}

resource "aws_iam_role_policy" "step_functions" {
  name = "windows-maintenance-step-functions-policy"
  role = aws_iam_role.step_functions.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:CreateSnapshot"
        ]

        Resource = "*"
      },
      {
        Effect = "Allow"

        Action = [
          "sns:Publish"
        ]

        Resource = aws_sns_topic.maintenance.arn
      },
      {
        Effect = "Allow"

        Action = [
          "ssm:SendCommand",
          "ssm:GetCommandInvocation",
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstanceInformation"
        ]

        Resource = "*"
      }
    ]
  })
}