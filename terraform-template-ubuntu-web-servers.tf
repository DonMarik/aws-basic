# Terraform template for my account

variable "access_key" {}
variable "secret_key" {}
variable "region" {
    default = "eu-west-1"
}
variable "amis" {
    type = "map"
    default = {
        "eu-west-1" = "ami-00035f41c82244dab"
    }
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
variable "key_name" {
    type = "string"
    default = "ec2key"
}
variable "environment" {
    type = "string"
}
variable "application" {
    type = "string"
}
variable "mgmt_ips" {
    default = ["0.0.0.0/0"]
}

provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_s3_bucket" "ma-s3-bucket-eu-1" {
    bucket = "ma-s3-bucket-eu-1-data"
    region = "${var.region}"
    acl = "private"

    tags {
        Name = "${var.environment}-BUCKETEU001"
        Environment = "${var.environment}"
    }
}

resource "aws_instance" "ma-webserver-1" {
    # mapped ami
    ami = "${lookup(var.amis, var.region)}"
    # latest ubuntu ami
    #ami = "${data.aws_ami.ubuntu.id}"
    instance_type = "t2.micro"
    tags {
        Name = "${var.environment}-WEB001"
        Environment = "${var.environment}"
        sshUser = "ubuntu"
        serverGroup = "webservers"
        serverStack = "automation_stack"
    }
    key_name = "${aws_key_pair.ma-keypair.key_name}"
    depends_on = ["aws_s3_bucket.ma-s3-bucket-eu-1"]
    subnet_id = "${aws_subnet.pub-web-az-a.id}"
    vpc_security_group_ids = ["${aws_security_group.WebserverSG.id}"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.ma-webserver-1.public_ip} > ip_address-web1.txt"
    }
}

resource "aws_instance" "ma-webserver-2" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    tags {
        Name = "${var.environment}-WEB002"
        Environment = "${var.environment}"
        sshUser = "ubuntu"
        serverGroup = "webservers"
        serverStack = "automation_stack"
    }
    key_name = "${aws_key_pair.ma-keypair.key_name}"
    depends_on = ["aws_s3_bucket.ma-s3-bucket-eu-1"]
    subnet_id = "${aws_subnet.pub-web-az-b.id}"
    vpc_security_group_ids = ["${aws_security_group.WebserverSG.id}"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.ma-webserver-2.public_ip} > ip_address-web2.txt"
    }
}

resource "aws_instance" "ma-dbserver-1" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    tags {
        Name = "${var.environment}-DB001"
        Environment = "${var.environment}"
        sshUser = "ubuntu"
        serverGroup = "dbservers"
        serverStack = "automation_stack"
    }
    key_name = "${aws_key_pair.ma-keypair.key_name}"
    depends_on = ["aws_s3_bucket.ma-s3-bucket-eu-1"]
    subnet_id = "${aws_subnet.priv-db-az-a.id}"
    vpc_security_group_ids = ["${aws_security_group.DBServerSG.id}"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.ma-dbserver-1.public_ip} > ip_address-db1.txt"
    }
}

resource "aws_instance" "ma-dbserver-2" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    tags {
        Name = "${var.environment}-DB002"
        Environment = "${var.environment}"
        sshUser = "ubuntu"
        serverGroup = "dbservers"
        serverStack = "automation_stack"
    }
    key_name = "${aws_key_pair.ma-keypair.key_name}"
    depends_on = ["aws_s3_bucket.ma-s3-bucket-eu-1"]
    subnet_id = "${aws_subnet.priv-db-az-b.id}"
    vpc_security_group_ids = ["${aws_security_group.DBServerSG.id}"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.ma-dbserver-2.public_ip} > ip_address-db2.txt"
    }
}

resource "aws_instance" "ma-bastion-1" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    tags {
        Name = "${var.environment}-BASTION001"
        Environment = "${var.environment}"
        sshUser = "ubuntu"
        serverGroup = "bastionservers"
        serverStack = "automation_stack"
    }
    key_name = "${aws_key_pair.ma-keypair.key_name}"
    depends_on = ["aws_s3_bucket.ma-s3-bucket-eu-1"]
    subnet_id = "${aws_subnet.pub-web-az-a.id}"
    vpc_security_group_ids = ["${aws_security_group.bastionhostSG.id}"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.ma-bastion-1.public_ip} > ip_address-bastion1.txt"
    }
}

resource "aws_instance" "ma-bastion-2" {
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "t2.micro"
    tags {
        Name = "${var.environment}-BASTION002"
        Environment = "${var.environment}"
        sshUser = "ubuntu"
        serverGroup = "bastionservers"
        serverStack = "automation_stack"
    }
    key_name = "${aws_key_pair.ma-keypair.key_name}"
    depends_on = ["aws_s3_bucket.ma-s3-bucket-eu-1"]
    subnet_id = "${aws_subnet.pub-web-az-b.id}"
    vpc_security_group_ids = ["${aws_security_group.bastionhostSG.id}"]

    provisioner "local-exec" {
        command = "echo ${aws_instance.ma-bastion-2.public_ip} > ip_address-bastion2.txt"
    }
}

resource "aws_eip" "ma-eip-1" {
    instance = "${aws_instance.ma-webserver-1.id}"
}

resource "aws_eip" "ma-eip-2" {
    instance = "${aws_instance.ma-webserver-2.id}"
}

resource "aws_elb" "ma-lb-1" {
    name_prefix = "${var.environment}-"
    subnets = ["${aws_subnet.pub-web-az-a.id}", "${aws_subnet.pub-web-az-b.id}"]
    health_check {
        healthy_threshold = 2
        unhealthy_threshold = 2
        timeout = 3
        target = "HTTP:80/"
        interval = 30
    }
    listener {
        instance_port = 80
        instance_protocol = "http"
        lb_port = 80
        lb_protocol = "http"
    }
    cross_zone_load_balancing = true
    instances = ["${aws_instance.ma-webserver-1.id}", "${aws_instance.ma-webserver-2.id}"]
    security_groups = ["${aws_security_group.LoadBalancerSG.id}"]
}

output "ami" {
  value = "${lookup(var.amis, var.region)}"
}
