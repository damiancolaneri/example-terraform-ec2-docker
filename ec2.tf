resource "aws_key_pair" "key_pair" {
  key_name   = "key_damian"
  public_key = file("./id_rsa.pub")
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "docker" {
  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t2.medium"
  subnet_id                   = element(module.vpc.public_subnets, 0)
  key_name                    = aws_key_pair.key_pair.key_name
  vpc_security_group_ids      = [aws_security_group.docker.id]
  associate_public_ip_address = true

  tags = {
    Name = "docker-${var.name}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install docker -y",
      "sudo yum install docker conntrack git -y",
      "sudo service docker start",
      "sudo usermod -a -G docker ec2-user",
      "sudo chown ec2-user:docker /var/run/docker.sock",
      "sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "mkdir docker"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("./id_rsa")
      host        = self.public_ip
    }
  }

}

