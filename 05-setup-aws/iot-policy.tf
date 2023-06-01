# create and attache policy
resource "random_id" "policy_id" {
  byte_length = 8
}

resource "aws_iot_policy" "policy" {
  name = "thingpolicy_${random_id.policy_id.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:*",
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iot_policy_attachment" "attachment" {
  policy = aws_iot_policy.policy.name
  target = aws_iot_certificate.cert.arn
}