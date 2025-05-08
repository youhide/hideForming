resource "minio_s3_bucket" "bucket" {
  for_each = var.enabled ? { for idx, param in var.minio_parameters : param.bucket_name != null ? param.bucket_name : "bucket-${idx}" => param } : {}

  bucket        = each.value.bucket_name
  force_destroy = each.value.force_destroy
  acl           = each.value.bucket_acl
}
