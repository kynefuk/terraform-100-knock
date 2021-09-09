data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64*"]
  }
}

resource "aws_launch_configuration" "lc" {
  name            = "${var.project}_lc"
  image_id        = data.aws_ami.ubuntu_20_04.id
  instance_type   = "t2.nano"
  security_groups = [aws_security_group.private.id]
  user_data       = <<EOF
#!/bin/bash
set -xe
timedatectl set-timezone Asia/Tokyo
apt update -y
apt install -y nginx
EOF

}

resource "aws_autoscaling_group" "ag" {
  name_prefix               = "${var.project}_ag_"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "ELB"
  force_delete              = true
  launch_configuration      = aws_launch_configuration.lc.id
  # availability_zones        = var.az
  vpc_zone_identifier = tolist(aws_subnet.private.*.id)
  enabled_metrics     = ["GroupInServiceCapacity"]
  target_group_arns   = [aws_lb_target_group.http.arn]
}

# resource "aws_autoscaling_attachment" "ag_attach" {
#   autoscaling_group_name = aws_autoscaling_group.ag.id
#   elb                    = aws_lb.app_lb.id
#   alb_target_group_arn   = aws_lb_target_group.http.arn
# }

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project}_scale_out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.ag.name
}

resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project}_scale_in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 120
  autoscaling_group_name = aws_autoscaling_group.ag.name
}
