######################
# S3 WEB CERTIFICATE #
######################

resource "aws_acm_certificate" "s3_web" {
  domain_name               = var.s3_web_domain
  validation_method         = "DNS"
}

resource "aws_route53_record" "s3_web" {
  for_each = {
    for d in aws_acm_certificate.s3_web.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.hosted_zone_id
}

resource "aws_acm_certificate_validation" "s3_web" {
  certificate_arn         = aws_acm_certificate.s3_web.arn
  validation_record_fqdns = [for r in aws_route53_record.s3_web : r.fqdn]
}


#################
# S3 WEB BUCKET #
#################

resource "aws_s3_bucket" "iot" {
  bucket_prefix = var.s3_web_domain

  tags = {
    "SubDomain" = "iot"
    "Domain"   = "dhanuzone"
    "ManagedBy" = "terraform"
  }

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "iot" {
  bucket = aws_s3_bucket.iot.id

  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_website_configuration" "iot" {
  bucket = aws_s3_bucket.iot.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}

data "aws_iam_policy_document" "iot" {
  statement {
    actions = ["s3:GetObject"]

    resources = [
      aws_s3_bucket.iot.arn,
      "${aws_s3_bucket.iot.arn}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.iot.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "iot" {
  bucket = aws_s3_bucket.iot.id
  policy = data.aws_iam_policy_document.iot.json
}


##############
# CLOUDFRONT #
##############

resource "aws_cloudfront_origin_access_identity" "iot" {
  comment = "OAI for ${var.s3_web_domain}"
}

resource "aws_cloudfront_distribution" "iot" {
  enabled             = true
  aliases             = [var.s3_web_domain]
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.iot.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.iot.id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.iot.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.iot.id
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers      = []
      query_string = true

      cookies {
        forward = "all"
      }
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["NZ", "AU", "US"]
    }
  }

  tags = {
    "Project"   = "dhanuzone"
    "ManagedBy" = "terraform"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.s3_web.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = 10
    response_page_path    = "/index.html"
    response_code         = 200
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = 10
    response_page_path    = "/index.html"
    response_code         = 200
  }
}

resource "aws_route53_record" "dhanuzone" {
  name    = var.s3_web_domain
  zone_id = var.hosted_zone_id
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.iot.domain_name
    zone_id                = aws_cloudfront_distribution.iot.hosted_zone_id
    evaluate_target_health = true
  }
}