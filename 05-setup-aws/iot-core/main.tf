##################
# IOT-CORE THING #
##################

resource "random_id" "thing_id" {
  byte_length = 8
}

# create thing
resource "aws_iot_thing" "thing" {
  name = "sensortag_${random_id.thing_id.hex}"
}


########################
# IOT-CORE CERTIFICATE #
########################

# generate and assign private key
resource "tls_private_key" "key" {
  algorithm   = "RSA"
  rsa_bits = 2048
}

# generate and assign certificate
resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  validity_period_hours = 240

  allowed_uses = [
  ]

  subject {
    organization = "test"
  }
}

resource "aws_iot_certificate" "cert" {
  certificate_pem = trimspace(tls_self_signed_cert.cert.cert_pem)
  active          = true
}

resource "aws_iot_thing_principal_attachment" "attachment" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.thing.name
}

# get CA certificate
data "http" "root_ca" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}

# write key and cert into local files
resource "local_file" "private_key" {
  content  = tls_private_key.key.private_key_pem
  filename = "./certs/private.pem.key"
}

resource "local_file" "certificate" {
  content  = tls_self_signed_cert.cert.cert_pem
  filename = "./certs/certificate.pem.crt"
}

resource "local_file" "ca" {
  content  = data.http.root_ca.response_body
  filename = "./certs/AmazonRootCA1.pem"
}


###################
# IOT-CORE POLICY #
###################

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


#####################
# IOT-CORE ENDPOINT #
#####################

# export
data "aws_iot_endpoint" "iot_endpoint" {
  endpoint_type = "iot:Data-ATS"
}