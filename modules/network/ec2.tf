###############################################################################
# EC2 web server
#   - Latest Amazon Linux 2023 AMI (resolved via SSM public parameter)
#   - Lives in a public subnet serving HTTP; admin access via SSM, not SSH
###############################################################################

data "aws_ssm_parameter" "al2023_ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_security_group" "web" {
  name        = "${var.name_prefix}-web-sg"
  description = "Allow HTTP in, all traffic out"
  vpc_id      = aws_vpc.this.id

  tags = { Name = "${var.name_prefix}-web-sg" }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  for_each = toset(var.http_allowed_cidrs)

  security_group_id = aws_security_group.web.id
  description       = "HTTP"
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = each.value
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "All outbound"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_instance" "web" {
  count = var.create_ec2 ? 1 : 0

  ami                    = data.aws_ssm_parameter.al2023_ami.value
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.web.id]
  iam_instance_profile   = var.instance_profile_name

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y nginx
    echo "<h1>Hello from ${var.name_prefix}</h1>" > /usr/share/nginx/html/index.html
    systemctl enable --now nginx
  EOF

  # Enforce IMDSv2
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = { Name = "${var.name_prefix}-web" }

  lifecycle {
    # Don't replace the instance every time a new AMI is published.
    ignore_changes = [ami]
  }
}
