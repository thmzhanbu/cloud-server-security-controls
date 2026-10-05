# Stage one: private workload segmentation

Status: formatted, initialized, and validated with Terraform 1.16.5 and AWS provider 6.67.0 on 5 October 2026. Deployed and tested, then cleaned up; see cleanup verification for final status.

## Design

Three small Linux nodes occupy separate application, data, and test subnets in one Sydney availability zone. They have no public IP addresses, internet gateway, NAT gateway, or inbound SSH rules. Two private Systems Manager endpoints provide administration. The single availability zone is a cost trade-off, not a production availability design.

The application may connect to a simulated data listener on TCP 5432. The test node can attempt the same connection, but the data security group accepts only the application group. This distinguishes destination enforcement from a test that fails merely because the test source cannot send traffic. Security groups are stateful, so response traffic for accepted connections is allowed.

Session Manager permissions use an EC2 service role, not a role assigned to a human team member. Root volumes are encrypted; IMDSv2 is required; standard CPU credits prevent surplus-credit billing.

## Deployment gates

1. Restore AWS Toolkit connection and verify free-plan status, credits, available AZ, and current Amazon Linux 2023 AMI in Sydney.
2. Verify the AMI includes SSM Agent 3.3.40.0 or newer and Python 3. The two-endpoint design relies on modern ssmmessages support.
3. Verify current Sydney endpoint and gp3 rates and calculate a complete cost estimate. Three t3.micro nodes at the previously verified USD 0.0132/hour rate total USD 0.0396/hour for compute alone. This is not the full lab cost.
4. Install Terraform, format, initialize, validate, and inspect the plan. Keep state private and commit the provider lock file.
5. Supply verified AMI and AZ values; deploy only after reviewing the concrete plan and cost.

## Evidence to collect

- All three nodes registered with Systems Manager and without public IPs.
- Start a Python simulated data listener on the data node; verify it is listening locally before remote tests.
- Application → data TCP 5432 succeeds.
- Test node → data TCP 5432 times out despite source egress permission.
- Capture commands, timestamps, listener health, and actual outcomes; a timeout alone does not prove policy enforcement.
- Audit actual group rules, compare with the baseline, introduce one controlled extra source rule, detect it, and remove it.
- Destroy all tagged resources after evidence collection if the user chooses cleanup. Stopping instances does not stop endpoint and storage charges.

## Deferred integration

This stage has no general internet egress, package-download path, or Wazuh connection. Wazuh package staging and private telemetry transport require a separately reviewed design. No Wazuh monitoring results are claimed for the cloud lab yet.

## References

- https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-create-vpc.html
- https://docs.aws.amazon.com/vpc/latest/userguide/security-group-rules.html
- https://aws.amazon.com/privatelink/pricing/
