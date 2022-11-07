
module "base" {
  source="./base"
  tags = var.tags
  cluster-name = var.cluster-name
  env_name = var.env_name
  aws_region = var.aws_region
}



module "addons" {
  source = "./addons"
  cluster-name = var.cluster-name
  vpc_id = module.base.vpc_id
  aws_region = var.aws_region
  oidc_provider_arn =  module.base.oidc_provider_arn
  env_name = var.env_name

  depends_on = [
      module.base
  ]
}

module "apps"{
  source = "./apps"

  lb_dns_name = module.addons.lb_dns_name
  depends_on = [
    module.addons
  ]
}


resource "tls_private_key" "rsa-4096-private-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}



resource "aws_key_pair" "key_pair" {
  key_name   = "ec2-key"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.rsa-4096-private-key.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.rsa-4096-private-key.private_key_pem}' > ./myKey.pem"
  }
}


resource "aws_security_group" "ec2_sg" {
    name        = "ec2_sg"
    description = "Allow traffic"
    vpc_id      = module.base.vpc_id

    ingress {
      description      = "World"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

    egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }

  }

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


module "private_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-private-instance"

  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = module.base.private_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}


module "public_ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "single-public-instance"

  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.key_pair.key_name
  monitoring             = false
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  subnet_id              = module.base.public_subnets[0]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}
