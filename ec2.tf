resource "aws_instance" "ingestion" {
  ami = "${var.ec2_ami}"
  instance_type = "t2.micro"
  key_name = aws_key_pair.main.key_name
  subnet_id = aws_subnet.agi.id
  vpc_security_group_ids = [aws_security_group.ingestion.id]
  # iam_instance_profile = "${aws_iam_instance_profile.ingestion_profile.name}"

  tags = {
    name = "IngestionService"
    environment = "${var.environment}"
    project = "${var.project}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key}' ansible/setup-ingestion.yml"
  }
}

resource "aws_eip" "ingestion" {
  instance = aws_instance.ingestion.id
  vpc      = true

  tags = {
    name = "IngestionIP"
    environment = "${var.environment}"
    project = "${var.project}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "ingestion" {
  name = "ingestion"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 1883
    to_port     = 1883
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

resource "aws_key_pair" "main" {
  key_name   = "main"
  public_key = file(var.pub_key)
}

output "telegraf_ip" {
  value       = aws_eip.ingestion.public_ip
  description = "IP of Telegraf server"
}

resource "aws_instance" "grafana_server" {
  ami = "${var.ec2_ami}"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.agi.id
  key_name = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.grafana_server.id]

  tags = {
    name = "GrafanaServer"
    environment = "${var.environment}"
    project = "${var.project}"
  }

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.pvt_key)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '${self.public_ip},' --private-key ${var.pvt_key} -e 'pub_key=${var.pub_key} efs_mountpoint=${aws_efs_file_system.grafana_storage.dns_name}' ansible/setup-grafana.yml"
  }
}

resource "aws_security_group" "grafana_server" {
  name = "grafana_server"
  vpc_id      = "${aws_vpc.main.id}"

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_eip" "grafana_server" {
  instance = aws_instance.grafana_server.id
  vpc      = true

  tags = {
    name = "GrafanaIP"
    environment = "${var.environment}"
    project = "${var.project}"
  }

  lifecycle {
    prevent_destroy = true
  }
}

output "grafana_ip" {
  value       = aws_eip.grafana_server.public_ip
  description = "IP of Grafana server"
}
