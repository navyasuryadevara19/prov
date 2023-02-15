variable "region" {
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "server_ports" {
  type    = list(any)
  default = [22, 80]
}

variable "destination_cidr" {
  default = "0.0.0.0/0"
}

variable "custom_tags" {
  type = map(any)
  default = {
    Name = "Webserver"
    ENV  = "Dev"
  }
}

output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
}
