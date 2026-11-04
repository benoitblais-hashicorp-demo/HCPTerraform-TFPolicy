# HCPTerraform-TFPolicy

Terraform Policy (TFPolicy) policy set for HCP Terraform, delivered through VCS integration.

## Structure

```text
.
├── README.md
└── policies/
    ├── <name>.policy.hcl        # policy
    └── <name>.policytest.hcl    # tests for that policy (same base name)
```

## Policies

| Policy | Scope | Rule |
| --- | --- | --- |
| [`aws-creation-date-tag`](policies/aws-creation-date-tag.policy.hcl) | Taggable AWS resources | Must have a `creation_date` tag with a valid `yyyy-mm-dd` date. |

## Testing

Requires the `tfpolicy` CLI.

```bash
tfpolicy test --policies=./policies --tests=./policies
```

`tfpolicy test` only evaluates `condition` expressions and mocks `meta`; also validate with a real
plan (`terraform plan --policies=...`) before enforcing.

## HCP Terraform

Point the policy set's policies path at `policies/` and attach it to the target projects/workspaces.
