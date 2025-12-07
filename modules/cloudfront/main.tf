# CloudFront VPC Origin for Internal ALB
resource "aws_cloudfront_vpc_origin" "alb" {
  vpc_origin_endpoint_config {
    name                   = "${var.name_prefix}-vpc-origin"
    arn                    = var.alb_arn
    http_port              = 80
    https_port             = 443
    origin_protocol_policy = "http-only"

    origin_ssl_protocols {
      items    = ["TLSv1.2"]
      quantity = 1
    }
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-vpc-origin"
  })
}

# Use AWS Managed CachingDisabled policy for WebSocket/dynamic content
# Policy ID: 4135ea2d-6df8-44a3-9df3-4b5a84be39ad (Managed-CachingDisabled)
data "aws_cloudfront_cache_policy" "caching_disabled" {
  name = "Managed-CachingDisabled"
}

# CloudFront Origin Request Policy
resource "aws_cloudfront_origin_request_policy" "vscode" {
  name    = "${var.name_prefix}-origin-request-policy"
  comment = "Origin request policy for VSCode Web"

  cookies_config {
    cookie_behavior = "all"
  }
  headers_config {
    header_behavior = "allViewerAndWhitelistCloudFront"
    headers {
      items = ["CloudFront-Forwarded-Proto"]
    }
  }
  query_strings_config {
    query_string_behavior = "all"
  }
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "vscode" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.name_prefix} VSCode Web Distribution"
  price_class         = var.price_class
  wait_for_deployment = true

  origin {
    domain_name = var.alb_dns_name
    origin_id   = "alb-origin"

    vpc_origin_config {
      vpc_origin_id            = aws_cloudfront_vpc_origin.alb.id
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "alb-origin"

    cache_policy_id          = data.aws_cloudfront_cache_policy.caching_disabled.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.vscode.id

    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
    minimum_protocol_version       = "TLSv1.2_2021"
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-distribution"
  })
}
