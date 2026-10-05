# Stage-one results — 5 October 2026

Terraform apply completed: 29 resources added. Three t3.micro nodes run in private subnets without public IP addresses. All three are Online in Systems Manager with Agent 3.3.5226.0.

The data node runs a simulated Python TCP listener, not a database. Local listener health passed. Application-to-data TCP 5432 returned the expected banner. The probe-to-data connection timed out; its source egress rule permits the attempt, and the destination has only the application-source ingress rule. Both final connectivity tests passed. See evidence/segmentation-baseline.json.

The first probe run misclassified Python 3.9 socket.timeout as an error. The script now handles both socket.timeout and TimeoutError; the rerun passed.

This section records the initial deployment. Later stages completed Wazuh integration, drift auditing, and controlled recovery; see the README result table and cleanup verification for final status.

## Controlled policy drift and recovery

The focused Python audit passed against the baseline. A temporary source-group rule then allowed the disposable probe to connect to TCP 5432 on the data node. The audit correctly returned FAIL and identified that unexpected ingress rule; the probe received the simulated service banner. The temporary rule was removed in a finally block. The restored audit returned PASS and a fresh probe test timed out as expected.

Actual console and evidence-report screenshots are saved under evidence/. The report screenshot is not presented as the AWS console. No extra drift rule remains.
