resource "aws_db_instance" "dbin" {
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = "myapp_db"
  username            = "admin"
  password            = "${var.db_pwd}"
  publicly_accessible = false
  vpc_security_group_ids = ["${aws_security_group.dbisg.id}"]
  skip_final_snapshot = true
}


resource "aws_security_group" "dbisg" {
  name = "dbisg"

 ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.instance.id}"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}
