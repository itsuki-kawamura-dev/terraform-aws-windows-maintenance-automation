resource "aws_iam_role" "ec2_ssm" {
  name = "windows-maintenance-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = "windows-maintenance-automation"
  }
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "windows-maintenance-ec2-ssm-profile"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_iam_role" "patch_scan_lambda" {
  name = "windows-patch-scan-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "lambda.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.patch_scan_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "patch_scan_ssm" {
  name = "windows-patch-scan-ssm"
  role = aws_iam_role.patch_scan_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ssm:SendCommand"
        ]

        Resource = [
          "arn:aws:ssm:*::document/AWS-RunPatchBaseline",
          "arn:aws:ec2:*:*:instance/*"
        ]
      },
      {
        Effect = "Allow"

        Action = [
          "ssm:ListCommandInvocations",
          "ssm:DescribeInstancePatchStates"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "patch_scan_stepfunctions" {
  name = "windows-patch-scan-stepfunctions"
  role = aws_iam_role.patch_scan_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "states:StartExecution"
        ]

        Resource = aws_sfn_state_machine.windows_maintenance.arn
      }
    ]
  })
}