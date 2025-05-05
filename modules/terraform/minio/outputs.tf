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
