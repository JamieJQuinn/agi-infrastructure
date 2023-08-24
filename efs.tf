resource "aws_efs_file_system" "grafana_storage" {
  performance_mode = "generalPurpose"

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  tags = {
    name = "GrafanaStorage"
    environment = "${var.environment}"
  }
}

resource "aws_efs_access_point" "grafana_storage" {
  file_system_id = aws_efs_file_system.grafana_storage.id
}

resource "aws_efs_file_system_policy" "grafana_storage" {
  file_system_id = aws_efs_file_system.grafana_storage.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Id": "Policy01",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Principal": {
                "AWS": "*"
            },
            "Resource": "${aws_efs_file_system.grafana_storage.arn}",
            "Action": [
                "elasticfilesystem:ClientMount",
                "elasticfilesystem:ClientRootAccess",
                "elasticfilesystem:ClientWrite"
            ],
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_efs_mount_target" "grafana_storage" {
  file_system_id = aws_efs_file_system.grafana_storage.id
  subnet_id = aws_subnet.agi.id
  security_groups = [aws_security_group.grafana_storage.id]
}

resource "aws_security_group" "grafana_storage" {
  name = "grafana_storage"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }
}
