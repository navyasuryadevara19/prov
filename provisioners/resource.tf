resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.aws_linux_2_latest.id
  instance_type          = var.instance_type
  user_data              = file("./scripts/install_httpd.sh")
  vpc_security_group_ids = [aws_security_group.webserver_sg.id]
  key_name               = "terraform"
  tags = {

    Name = var.custom_tags["Name"]
    ENV  = var.custom_tags["ENV"]
  }
}

data "aws_ami" "aws_linux_2_latest" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

resource "aws_security_group" "webserver_sg" {
  name        = "webserver SG"
  description = "Allow TLS inbound traffic"

  dynamic "ingress" {
    iterator = port
    for_each = var.server_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [var.destination_cidr]
    }
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "webserver SG"
  }
}


resource "null_resource" "provisioners" {
depends_on = [
aws_instance.webserver
]

  provisioner "local-exec" {
    command = "echo welcome to terraform provisioners V2 > ./files/index.html"
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = aws_instance.webserver.public_ip
    private_key = file("./terraform.pem")
  }

  provisioner "file" {
  source = "./files/"
  destination = "/tmp/"
  }

  provisioner "remote-exec" {
  inline = [
  "sleep 60",
"sudo cp /tmp/index.html /var/www/html",
  ]
  }
}
