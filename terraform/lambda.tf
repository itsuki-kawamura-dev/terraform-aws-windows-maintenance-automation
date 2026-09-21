data "archive_file" "patch_scan" {
  type        = "zip"
  source_file = "${path.module}/lambda/patch_scan.py"
  output_path = "${path.module}/patch_scan.zip"
}

resource "aws_lambda_function" "patch_scan" {
  function_name = "windows-patch-scan"

  role    = aws_iam_role.patch_scan_lambda.arn
  handler = "patch_scan.lambda_handler"
  runtime = "python3.13"

  filename         = data.archive_file.patch_scan.output_path
  source_code_hash = data.archive_file.patch_scan.output_base64sha256

  timeout = 300
  environment {
    variables = {
      STATE_MACHINE_ARN = aws_sfn_state_machine.maintenance.arn
    }
  }
}