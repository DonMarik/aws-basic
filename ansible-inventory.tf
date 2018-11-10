resource "ansible_host" "ma-bastion-1" {
  inventory_hostname = "${aws_instance.ma-bastion-1.public_dns}"
  groups = ["bastionservers"]
  vars
  {
      ansible_user = "ubuntu"
      ansible_ssh_private_key_file="/opt/terraform/aws-basic/privkey.pem"
      ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
      ansible_python_interpreter="/usr/bin/python3"
  }
}

resource "ansible_host" "ma-bastion-2" {
  inventory_hostname = "${aws_instance.ma-bastion-2.public_dns}"
  groups = ["bastionservers"]
  vars
  {
      ansible_user = "ubuntu"
      ansible_ssh_private_key_file="/opt/terraform/aws-basic/privkey.pem"
      ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
      ansible_python_interpreter="/usr/bin/python3"
  }
}


resource "ansible_host" "ma-webserver-1" {
  inventory_hostname = "${aws_instance.ma-webserver-1.private_dns}"
  groups = ["webservers"]
  vars
  {
      ansible_user = "ubuntu"
      ansible_ssh_private_key_file="/opt/terraform/aws-basic/privkey.pem"
      ansible_python_interpreter="/usr/bin/python3"
      ansible_ssh_common_args= " -o ProxyCommand=\"ssh -i /opt/terraform/aws-basic/privkey.pem -W %h:%p -q ubuntu@${aws_instance.ma-bastion-1.public_dns}\""
      ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
      proxy = "${aws_instance.ma-bastion-1.private_ip}"
  }
}

resource "ansible_host" "ma-webserver-2" {
  inventory_hostname = "${aws_instance.ma-webserver-2.private_dns}"
  groups = ["webservers"]
  vars
  {
      ansible_user = "ubuntu"
      ansible_ssh_private_key_file="/opt/terraform/aws-basic/privkey.pem"
      ansible_python_interpreter="/usr/bin/python3"
      ansible_ssh_common_args= " -o ProxyCommand=\"ssh -i /opt/terraform/aws-basic/privkey.pem -W %h:%p -q ubuntu@${aws_instance.ma-bastion-2.public_dns}\""
      ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
      proxy = "${aws_instance.ma-bastion-2.private_ip}"
  }
}

resource "ansible_host" "ma-dbserver-1" {
  inventory_hostname = "${aws_instance.ma-dbserver-1.private_dns}"
  groups = ["dbservers"]
  vars
  {
      ansible_user = "ubuntu"
      ansible_ssh_common_args= " -o ProxyCommand=\"ssh -i /opt/terraform/aws-basic/privkey.pem -W %h:%p -q ubuntu@${aws_instance.ma-bastion-1.public_dns}\""
      ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
      ansible_ssh_private_key_file="/opt/terraform/aws-basic/privkey.pem"
      ansible_python_interpreter="/usr/bin/python3"
      proxy = "${aws_instance.ma-bastion-1.private_ip}"
  }
}

resource "ansible_host" "ma-dbserver-2" {
  inventory_hostname = "${aws_instance.ma-dbserver-2.private_dns}"
  groups = ["dbservers"]
  vars
  {
      ansible_user = "ubuntu"
      ansible_ssh_common_args= " -o ProxyCommand=\"ssh -i /opt/terraform/aws-basic/privkey.pem -W %h:%p -q ubuntu@${aws_instance.ma-bastion-2.public_dns}\""
      ansible_ssh_extra_args="-o StrictHostKeyChecking=no"
      ansible_ssh_private_key_file="/opt/terraform/aws-basic/privkey.pem"
      ansible_python_interpreter="/usr/bin/python3"
      proxy = "${aws_instance.ma-bastion-2.private_ip}"
  }
}