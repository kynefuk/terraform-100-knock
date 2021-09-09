resource "aws_cloudwatch_metric_alarm" "instance_cpu" {
  alarm_name                = "${var.project}_cpu"
  namespace                 = "AWS/EC2"
  metric_name               = "CPUUtilization"
  statistic                 = "Average"
  threshold                 = "60"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  period                    = "60"
  evaluation_periods        = "1"
  insufficient_data_actions = [""]
  treat_missing_data        = "breaching"
  alarm_actions             = [aws_autoscaling_policy.scale_out.arn]
  ok_actions                = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    "AutoScalingGroupName" = aws_autoscaling_group.ag.name
  }
}
