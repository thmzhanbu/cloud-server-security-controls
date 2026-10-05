# Preflight — 4 October 2026

Verified through the AWS MCP connection:

- Project plan: FREE, ACTIVE.
- Remaining credit balance: USD 100.
- Selected Region: ap-southeast-2 (confirmed in AWS Settings screenshot on 5 October 2026).
- No EC2 instances returned in the selected Region.
- Only the default VPC was returned.
- t3.micro and t3.small are available candidate types. Eligibility labels do not imply zero cost.
- Terraform is not installed locally.
- Planning budget: USD 10, selected by the assistant under user authorization; not an automatic cutoff.

No AWS resources have been created for this lab.

## Proposed design to price

- A dedicated VPC with application and data subnet boundaries.
- Session Manager administration, without inbound SSH.
- Workload access policies expressed as standalone security group rules.
- Simulated data service and explicit positive/negative connection tests.
- Standard CPU credit mode for burstable instances to avoid surplus-credit charges.
- Encrypted root storage and required IMDSv2.

Private-only administration requires paid interface endpoints or a costed egress path. Bootstrap downloads and connectivity to the VMware Wazuh manager must be resolved before selecting the final design.

## Guardrails

- Create resources only in ap-southeast-2.
- Keep the existing default VPC untouched.
- Tag lab resources for inventory and cleanup.
- Do not upgrade the project to a paid plan without explicit authorization.
- Record actual costs and destroy lab resources once evidence is captured, subject to the user's retention choice.
