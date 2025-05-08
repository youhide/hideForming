output "buckets" {
  description = "Information about all created MinIO buckets"
  value = length(minio_s3_bucket.bucket) > 0 ? {
    for name, bucket in minio_s3_bucket.bucket : name => {
      id            = bucket.id
      bucket        = bucket.bucket
      acl           = bucket.acl
      force_destroy = bucket.force_destroy
    }
  } : null
}

output "service_accounts" {
  description = "Information about all created MinIO service accounts"
  value = length(minio_iam_service_account.user_sa) > 0 ? {
    for name, sa in minio_iam_service_account.user_sa : name => {
      id          = sa.id
      access_key  = sa.access_key
      secret_key  = sa.secret_key
      target_user = sa.target_user
      key         = name
    }
  } : null
  sensitive = true
}

output "service_account_keys" {
  description = "Keys of all created MinIO service accounts, useful for dependencies"
  value       = length(minio_iam_service_account.user_sa) > 0 ? keys(minio_iam_service_account.user_sa) : []
}
