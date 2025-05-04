resource "minio_iam_user" "user" {
  for_each = var.enabled ? { for idx, param in var.minio_parameters : param.bucket_name != null ? param.bucket_name : "bucket-${idx}" => param } : {}

  name          = each.value.bucket_name
  force_destroy = each.value.force_destroy
}
