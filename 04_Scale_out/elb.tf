resource "aws_lb" "app_lb" {
  name_prefix        = "app"
  load_balancer_type = "application"
  subnets            = tolist(aws_subnet.public.*.id)
  security_groups    = [aws_security_group.public.id]

  tags = {
    "Name" = "${var.project}_app_lb"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_target_group" "http" {
  name_prefix = "group"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    port                = 80
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 15
    matcher             = "200,201,301"
    path                = "/"
  }
}
