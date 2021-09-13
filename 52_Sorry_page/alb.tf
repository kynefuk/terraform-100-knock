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
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.for_alb.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }

  depends_on = [
    aws_acm_certificate.for_alb,
    aws_acm_certificate_validation.for_alb
  ]
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
    healthy_threshold   = 2
    unhealthy_threshold = 3
    timeout             = 2
    interval            = 5
    matcher             = "200,201,301"
    path                = "/"
  }
}

resource "aws_lb_target_group_attachment" "nginx" {
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = aws_instance.nginx.id
  port             = 80
}


resource "aws_lb_listener_certificate" "hoge" {
  listener_arn    = aws_lb_listener.https.arn
  certificate_arn = aws_acm_certificate.for_alb.arn
  depends_on = [
    aws_acm_certificate.for_alb,
    aws_acm_certificate_validation.for_alb
  ]
}
