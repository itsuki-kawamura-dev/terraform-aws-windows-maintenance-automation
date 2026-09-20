data "aws_ssm_parameter" "windows_ami" {
  name = "/aws/service/ami-windows-latest/Windows_Server-2022-English-Full-Base"
}

resource "aws_security_group" "windows" {
  name        = "windows-maintenance-sg"
  description = "Security group for Windows maintenance instance"
  vpc_id      = aws_vpc.main.id

  # No inbound rules
  # Administration is performed through AWS Systems Manager.

  egress {
    description = "Allow outbound traffic for SSM and Windows Update"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "windows-maintenance-sg"
    Project = "windows-maintenance-automation"
  }
}

resource "aws_instance" "windows" {
  ami                    = data.aws_ssm_parameter.windows_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.windows.id]

  associate_public_ip_address = false

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 30
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name    = "windows-maintenance-server"
    Project = "windows-maintenance-automation"
  }

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core
  ]
}