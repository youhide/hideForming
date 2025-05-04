resource "minio_iam_policy" "policy" {
  for_each = var.enabled ? { for idx, param in var.minio_parameters : param.bucket_name != null ? param.bucket_name : "bucket-${idx}" => param } : {}

  name   = "${each.value.bucket_name}-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetBucketLocation",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::${each.value.bucket_name}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ],
      "Resource": [
          "arn:aws:s3:::${each.value.bucket_name}/*"
      ]
    }
  ]
}
EOF
}

resource "minio_iam_user_policy_attachment" "policy_attachment" {
  for_each = var.enabled ? { for idx, param in var.minio_parameters : param.bucket_name != null ? param.bucket_name : "bucket-${idx}" => param } : {}

  user_name   = minio_iam_user.user[each.key].id
  policy_name = minio_iam_policy.policy[each.key].id
}
