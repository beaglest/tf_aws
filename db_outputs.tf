output "db_address" {
  value = "${aws_db_instance.dbin.address}"
}

output "db_port" {
  value = "${aws_db_instance.dbin.port}"
}
