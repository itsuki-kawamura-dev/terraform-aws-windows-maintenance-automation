resource "aws_sfn_state_machine" "maintenance" {
  name     = "windows-maintenance-automation"
  role_arn = aws_iam_role.step_functions.arn

  definition = templatefile(
    "${path.module}/statemachine/maintenance.asl.json",
    {
      instance_id   = aws_instance.windows.id
      sns_topic_arn = aws_sns_topic.maintenance.arn
    }
  )

  tags = {
    Project = "windows-maintenance-automation"
  }
}