variable "access_key" {}
variable "secret_key" {}

provider "aws" {
	access_key = "${var.access_key}"
	secret_key = "${var.secret_key}"
	region = "eu-west-1"
}

resource "aws_elb" "web" {
  name = "example-elb"
  availability_zones = ["eu-west-1a", "eu-west-1b"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 30
  }
	
}

resource "aws_autoscaling_group" "my_asg" {
	availability_zones = ["eu-west-1a", "eu-west-1b"]
	name = "web-test"
	max_size = "3"
	min_size = "1"
	desired_capacity = "1"
	health_check_type = "ELB"
	health_check_grace_period = 300
	load_balancers = ["${aws_elb.web.id}"]
	launch_configuration = "${aws_launch_configuration.asg_config.name}"

	tag {
		key = "Name"
		value = "web"
		propagate_at_launch = true
	}
}

resource "aws_autoscaling_group" "my_second_asg" {
	availability_zones = ["eu-west-1a", "eu-west-1b"]
	name = "web-test-second"
	max_size = "3"
	min_size = "1"
	desired_capacity = "2"
	health_check_type = "ELB"
	health_check_grace_period = 300
	load_balancers = ["${aws_elb.web.id}"]
	launch_configuration = "${aws_launch_configuration.asg_config.name}"

	tag {
		key = "Name"
		value = "web-second"
		propagate_at_launch = true
	}
}

resource "aws_launch_configuration" "asg_config" {
	image_id = "ami-f1810f86"
	instance_type = "t1.micro"
	key_name = "alese-dev"
	security_groups = ["web"]
	user_data = "${file("userdata.sh")}"
}

output "lb-dns" {
	value = "${aws_elb.web.dns_name}"
}