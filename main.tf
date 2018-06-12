provider "aws" {
  region = "eu-west-2"
}

resource "aws_launch_configuration" "alc" {
  image_id        = "ami-a36f8dc4"
  instance_type   = "t2.micro"
  security_groups = ["${aws_security_group.instance.id}"]
  user_data       = "${data.template_file.bootstrap.rendered}"
  key_name 	  = "MyWest2KeyPair"

  lifecycle {
    create_before_destroy = true
  }
}

data "template_file" "bootstrap" {
  template = "${file("bootstrap.sh")}"

  vars {
    rds_address  = "${aws_db_instance.dbin.address}"
    rds_dbname   = "${aws_db_instance.dbin.name}"
    rds_uname    = "${aws_db_instance.dbin.username}"
    rds_pwd      = "${aws_db_instance.dbin.password}"
  }
}

resource "aws_autoscaling_group" "aag" {
  launch_configuration = "${aws_launch_configuration.alc.id}"
  availability_zones   = ["${data.aws_availability_zones.all.names}"]

  load_balancers    = ["${aws_elb.alb.name}"]
  health_check_type = "ELB"

  min_size = 2
  max_size = 4

  tag {
    key                 = "Name"
    value               = "my-work"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "my-work-instance"

  ingress {
    from_port   = "${var.server_port}"
    to_port     = "${var.server_port}"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

 ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "alb" {
  name               = "my-elb"
  availability_zones = ["${data.aws_availability_zones.all.names}"]
  security_groups    = ["${aws_security_group.elb.id}"]

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "${var.server_port}"
    instance_protocol = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    target              = "HTTP:${var.server_port}/"
  }
}

resource "aws_security_group" "elb" {
  name = "my-work-elb"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
/*
resource "aws_cloudwatch_metric_alarm" "tne" {
  alarm_name                = "total_number_exceeds"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "RequestCount"
  namespace                 = "AWS/ELB"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "100"
  alarm_description         = "Total number of requests exceed 100"

  dimensions {
     LoadBalancerName = "${aws_elb.alb.name}"
  }
   
   alarm_actions     = ["${aws_elb.alb.arn}"]
}
*/
