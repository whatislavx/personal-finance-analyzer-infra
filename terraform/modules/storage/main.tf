resource "aws_s3_bucket" "results" {
  bucket = coalesce(var.s3_bucket_name_override, "${var.project_name}-${var.environment}-results-${var.account_id}")

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-results"
  })
}

resource "aws_s3_bucket" "tfstate" {
  bucket = coalesce(var.tfstate_bucket_name_override, "${var.project_name}-${var.environment}-tfstate-${var.account_id}")

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-tfstate"
  })
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "tfstate_locks" {
  name         = coalesce(var.tfstate_lock_table_name_override, "${var.project_name}-${var.environment}-tfstate-locks")
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-tfstate-locks"
  })
}

resource "aws_s3_bucket_public_access_block" "results" {
  bucket = aws_s3_bucket.results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "results" {
  bucket = aws_s3_bucket.results.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "results" {
  bucket = aws_s3_bucket.results.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}


