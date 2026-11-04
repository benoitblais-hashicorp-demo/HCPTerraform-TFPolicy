policytest {
  targets = ["aws-creation-date-tag.policy.hcl"]
}

# ---------------------------------------------------------------------------
# PASS cases
# ---------------------------------------------------------------------------

resource "aws_instance" "valid_date" {
  attrs = {
    tags = { creation_date = "2026-11-04" }
  }
}

resource "aws_s3_bucket" "valid_date_with_other_tags" {
  attrs = {
    tags = { Name = "demo", creation_date = "2024-02-29" } # leap day
  }
}

# Resource without a "tags" attribute (not taggable): out of scope, not evaluated.
resource "aws_s3_bucket_versioning" "not_taggable" {
  attrs = {
    bucket = "demo"
  }
}

# ---------------------------------------------------------------------------
# FAIL cases
# ---------------------------------------------------------------------------

# Tag key missing among other tags.
resource "aws_instance" "missing_tag" {
  expect_failure = true
  attrs = {
    tags = { Name = "demo" }
  }
}

# Taggable resource with an empty tag map.
resource "aws_vpc" "empty_tags" {
  expect_failure = true
  attrs = {
    tags = {}
  }
}

# Taggable resource with tags explicitly null (normalized to {} by the policy).
resource "aws_subnet" "null_tags" {
  expect_failure = true
  attrs = {
    tags = null
  }
}

# Empty value.
resource "aws_ebs_volume" "empty_value" {
  expect_failure = true
  attrs = {
    tags = { creation_date = "" }
  }
}

# Wrong format: dd/mm/yyyy.
resource "aws_sqs_queue" "wrong_format_slashes" {
  expect_failure = true
  attrs = {
    tags = { creation_date = "04/11/2026" }
  }
}

# Wrong format: missing zero padding.
resource "aws_sns_topic" "wrong_format_no_padding" {
  expect_failure = true
  attrs = {
    tags = { creation_date = "2026-1-5" }
  }
}

# Wrong format: includes a time component.
resource "aws_kms_key" "wrong_format_timestamp" {
  expect_failure = true
  attrs = {
    tags = { creation_date = "2026-11-04T10:00:00Z" }
  }
}

# Month out of range.
resource "aws_lambda_function" "invalid_month" {
  expect_failure = true
  attrs = {
    tags = { creation_date = "2026-13-01" }
  }
}

# Day out of range for the month (shape is valid, date is not).
resource "aws_dynamodb_table" "impossible_date" {
  expect_failure = true
  attrs = {
    tags = { creation_date = "2026-02-30" }
  }
}

# Key is case-sensitive.
resource "aws_efs_file_system" "wrong_key_case" {
  expect_failure = true
  attrs = {
    tags = { Creation_Date = "2026-11-04" }
  }
}
