# Cleanup

Preserve evidence first. Review `terraform plan -destroy` with the same variable values used for deployment. Empty only the dedicated package bucket's uploaded lab files, then apply the saved destroy plan. `force_destroy` is deliberately false so unexpected stored data prevents silent bucket deletion.

Verify Terraform state is empty, all four recorded instances are terminated, attached lab EBS disks are deleted, the VPC/endpoints are absent, the bucket is absent, and the instance profile/service role are deleted. Do not claim cleanup from a successful destroy command alone.

Stopping EC2 alone does not remove EBS or interface endpoint costs. The final verification result is recorded in `evidence/cleanup-verification.json`.

## Verified result — 5 October 2026

Terraform destroyed 50 resources. Independent API checks confirmed four terminated instances, no tagged lab volumes, VPCs, endpoints, or security groups, absent package bucket, and no lab service roles or instance profiles. Terraform state contains zero resources. This stops ongoing resource usage from this lab; delayed charges for prior usage may still appear.
