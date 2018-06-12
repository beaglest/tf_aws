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

}

