# aws-creation-date-tag
#
# Every taggable AWS resource must carry a "creation_date" tag whose value is a
# valid calendar date in the format yyyy-mm-dd (for example 2026-11-04).
#
# Scope:
#   - Evaluates every resource whose provider is "aws" and whose schema exposes a
#     "tags" attribute. Resources that do not support tags (for example
#     aws_s3_bucket_versioning) are skipped because they cannot carry the tag.
#   - Evaluates create and update operations only (default behavior); destroy is skipped.
#
# NOTE: Only the resource-level "tags" attribute is evaluated. Tags that come
# exclusively from the AWS provider "default_tags" block are not visible here, so
# set creation_date on the resource (or via a module/locals merge) itself.

resource_policy "*" "creation_date_tag_required" {
  enforcement_level = "mandatory"
  
  # core::try() falls back to "aws" when meta.provider_type is unavailable (tfpolicy test mocks).
  # The "tags" probe returns the sentinel only when the attribute is absent from the schema;
  # a taggable resource with tags = null is still evaluated (and fails below).
  filter = core::try(meta.provider_type, "aws") == "aws" && core::try(attrs.tags, "__no_tags_attribute__") != "__no_tags_attribute__"

  locals {
    tags_raw = core::try(attrs.tags, null)
    tags     = local.tags_raw != null ? local.tags_raw : {}

    value_raw = core::try(local.tags["creation_date"], null)
    value     = local.value_raw != null ? local.value_raw : ""

    # Strict yyyy-mm-dd shape with month 01-12 and day 01-31.
    has_valid_format = core::try(core::regex("^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$", local.value), null) != null

    # Rejects impossible dates such as 2026-02-30: timecmp errors on an invalid RFC3339 timestamp.
    is_real_date = core::try(core::timecmp("${local.value}T00:00:00Z", "${local.value}T00:00:00Z"), null) != null

    is_compliant = local.has_valid_format && local.is_real_date
  }

  enforce {
    condition     = local.is_compliant
    error_message = "AWS resources must have a 'creation_date' tag with a valid date in yyyy-mm-dd format (for example 2026-11-04)."
  }
}
