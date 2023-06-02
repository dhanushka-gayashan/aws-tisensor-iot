resource "random_id" "iot_inject_bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket" "iot_inject_bucket" {
  bucket = "iot-inject-bucket-${random_id.iot_inject_bucket_id.hex}"
}
