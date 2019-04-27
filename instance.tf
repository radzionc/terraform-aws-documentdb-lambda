data "aws_ami" "service" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "service" {
  ami           = "${data.aws_ami.service.id}"
  vpc_security_group_ids = ["${aws_security_group.service.id}"]
  subnet_id = "${module.vpc.public_subnets[0]}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.service.key_name}"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list",
      "sudo apt-get update",
      "sudo apt-get install -y mongodb-org-shell"
    ]
  }
  
  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = "${tls_private_key.service.private_key_pem}"
  }
}

resource "tls_private_key" "service" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "service" {
  key_name   = "tf-${var.name}-ec2"
  public_key = "${tls_private_key.service.public_key_openssh}"
}

resource "local_file" "service_private_key" {
  content = "${tls_private_key.service.private_key_pem}"
  filename = "${aws_key_pair.service.key_name}"
  provisioner "local-exec" {
    command = "chmod 400 ${aws_key_pair.service.key_name}"
  }
}