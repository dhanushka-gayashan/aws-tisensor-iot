# create thing
resource "random_id" "thing_id" {
  byte_length = 8
}

resource "aws_iot_thing" "thing" {
  name = "sensortag_${random_id.thing_id.hex}"
}

# export
output "thing_name" {
  value = aws_iot_thing.thing.name
}