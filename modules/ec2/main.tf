resource "aws_key_pair" "deployer" {
  key_name   = "${var.environment}-deployer-key"
  public_key = file(var.key_pair)
}

resource "aws_security_group" "instances" {
  name        = "${var.environment}-instance-sg"
  description = "Security group for ${var.environment} instances"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports
    content {
      description = "Allow port ${ingress.value.from_port}"
      from_port   = ingress.value.from_port
      to_port     = try(ingress.value.to_port, ingress.value.from_port)
      protocol    = "tcp"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.environment}-instance-sg"
  }
}

resource "aws_instance" "servers" {
  for_each = toset(var.servers_name)

  ami                    = var.ami_id[var.region]
  instance_type          = var.environment == "prod" ? "t2.large" : "t2.micro"
  key_name               = aws_key_pair.deployer.key_name
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.instances.id]

  root_block_device {
    volume_type           = "gp3"
    volume_size           = var.environment == "prod" ? 30 : 20
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name = each.key
  }

  lifecycle {
    create_before_destroy = true
  }
}
