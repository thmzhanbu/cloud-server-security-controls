# Screenshot and result evidence

- Original AWS EC2 console screenshot retained locally, excluded from publication because it includes project identifiers. API checks confirmed no public IP addresses.
- `02-policy-drift-and-recovery.jpg`: screenshot of a local report generated from actual saved AWS rule exports and Systems Manager outputs. It is explicitly labelled as a report, not the AWS console. Shows PASS → FAIL → PASS and probe access changing from allowed back to blocked.
- `segmentation-baseline.json`: application connection succeeded; unauthorized probe connection timed out; destination ingress policy was checked.
- `policy-baseline.json`, `policy-drift.json`, `policy-restored.json`: timestamped audit results.
- `connectivity-drift.json`, `connectivity-restored.json`: actual Systems Manager execution responses for the probe tests.

The audit is focused on the data group's inbound access. It is not a full VPC, IAM, host, or compliance assessment. Recovery removed only the extra test rule; no production infrastructure was involved. Cloud Wazuh integration produced a real-time file modification alert.

- `03-cloud-agent-health-and-fim.jpg`: browser screenshot of a report generated from actual agent health output and the Wazuh JSON alert; not a Wazuh dashboard.
- `fim-alert.json`: actual controlled modification alert, rule 550, with before/after hashes.
- `wazuh-health.json`: three Active agents before enrollment shutdown.

- `04-agent-disconnection-recovery.jpg`: report screenshot showing actual baseline, Disconnected, and restored Active manager outputs.
- `recovery-*.json`: timestamped live outputs for the controlled coverage-gap test.
