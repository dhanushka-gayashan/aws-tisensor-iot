data "aws_iam_policy_document" "iot_firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iot_firehose_role" {
  name               = "IotFirehoseROle"
  assume_role_policy = data.aws_iam_policy_document.iot_firehose_assume_role.json
}

data "aws_iam_policy_document" "iam_policy_for_iot_firehose" {
  statement {
    effect    = "Allow"
    actions   = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.iot_inject_bucket.arn,
      "${aws_s3_bucket.iot_inject_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy" "iam_policy_for_iot_firehose" {
  name   = "iotFireHosePolicy"
  role   = aws_iam_role.iot_firehose_role.id
  policy = data.aws_iam_policy_document.iam_policy_for_iot_firehose.json
}