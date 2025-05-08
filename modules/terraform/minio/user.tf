resource "minio_iam_user" "user" {
  for_each = var.enabled ? { for idx, param in var.minio_parameters : param.bucket_name != null ? param.bucket_name : "bucket-${idx}" => param } : {}

  name          = each.value.bucket_name
  force_destroy = each.value.force_destroy
}

resource "minio_iam_service_account" "user_sa" {
  for_each = var.enabled ? { for idx, param in var.minio_parameters : param.bucket_name != null ? param.bucket_name : "bucket-${idx}" => param } : {}

  target_user = minio_iam_user.user[each.key].name
}

