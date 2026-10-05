# Deployment and validation runbook

## Prerequisites

AWS CLI login profile `server-security-lab`, Terraform 1.6–1.x, Python 3, and permission to deploy the lab. Confirm selected Region and plan/spend status in AWS Settings. Use only ap-southeast-2. Review costs before applying.

## Infrastructure

From `terraform/`, initialize Terraform and provide an available Sydney AZ and a verified Amazon Linux 2023 x86_64 AMI with SSM Agent. The original run used ap-southeast-2a and ami-REDACTED; resolve a current AMI before reusing it.

```sh
terraform init
terraform fmt -check
terraform validate
terraform plan -var='ami_id=YOUR_VERIFIED_AMI' -var='availability_zone=ap-southeast-2a' -out=lab.tfplan
terraform apply lab.tfplan
terraform output -json
```

Review the plan for dedicated lab resources only. Wait for all four instances to appear Online in Systems Manager; verify encrypted disks, IMDSv2, and no public IP addresses.

## Workload and Wazuh configuration

1. Use Systems Manager Run Command to place `scripts/data-listener.py` on the data node and run it as a systemd service on TCP 5432. It simulates connectivity only.
2. On the operator machine, download the pinned Wazuh manager/agent x86_64 RPMs, matching official SHA-512 files, and Wazuh signing key from packages.wazuh.com. Verify hashes, upload packages into the lab bucket's `packages/` prefix, and generate short-lived presigned URLs. Do not save these URLs in evidence.
3. On the manager, fetch packages through the private S3 endpoint, import the official key, verify RPM signatures, and install the manager. Configure enrollment password authentication and a certificate matching the manager's private address. Store the password file as root:wazuh, mode 640.
4. Temporarily permit TCP 1515 from the three agent security groups in both required directions. The committed Terraform describes the final closed-enrollment state and is not sufficient by itself for initial enrollment.
5. Install the agent RPM on each node, set the manager's private address, enroll with its verified certificate and the temporary password, and use names cloud-app, cloud-data, cloud-probe.
6. Before starting each agent, create `/opt/server-controls-fim/config.txt` with a baseline and add this entry inside its `syscheck` section:

```xml
<directories check_all="yes" realtime="yes">/opt/server-controls-fim</directories>
```

7. Start services and verify the manager's agent list shows three Active agents. Disable manager enrollment, remove temporary password files, and remove TCP 1515 rules. Retain TCP 1514.

## Validation

Run `scripts/test-connection.py --help` for its connection options. Verify app → data succeeds and probe → data fails. Export the data security group's AWS rules, then run:

```sh
python3 scripts/audit-data-policy.py rules.json --app-group APP_SECURITY_GROUP_ID
```

The audit should return PASS at baseline. Add only a temporary probe-source TCP 5432 ingress rule to the disposable data group: the audit should FAIL and connectivity should succeed. Always remove that exact rule in a finally/recovery path and rerun both checks.

Wait for the first FIM scan and realtime monitoring to start. Modify the test file on cloud-app; read the manager's `alerts.json` for the exact path and agent name. Verify rule 550 and changed hashes. Use the agent recovery runbook for the coverage-gap test. Preserve outputs before cleanup.

This is the recorded operator workflow, not a fully automated bootstrap script. Avoid pasting secrets into terminal recordings or publishing raw SSM command parameters.
