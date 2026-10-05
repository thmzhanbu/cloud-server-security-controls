# Wazuh integration plan

Status: Terraform validated; reviewed plan adds 27 resources, changes none, destroys none. Not deployed yet.

## Architecture

A dedicated manager-only Wazuh 4.14.8 server runs on a private t3.small node with 2 GiB RAM, 2 vCPUs, and encrypted 20 GiB gp3 storage. This meets documented minimum memory and CPU, not recommended production sizing. There is no indexer or dashboard. Health and alerts will be read through Systems Manager.

Application, data, and probe nodes can reach only manager TCP 1514 (agent telemetry) and TCP 1515 (enrollment). No manager ports are publicly reachable. Enrollment must be protected with a temporary password; remove enrollment access after registration. Alert evidence will come from the manager's real alerts JSON, not synthetic screenshots.

A private encrypted S3 bucket stages official RPMs and the Wazuh signing key. Public access is blocked, insecure HTTP denied, and the gateway endpoint permits only GetObject within the lab package prefix. Temporary signed URLs permit download without expanding EC2 role permissions. URLs and enrollment secrets must never be committed or included in public evidence.

Package hashes are compared against Wazuh's published SHA-512 checksums, and RPM signatures must be checked on the server before installation. The gateway adds an S3 route and HTTPS egress to the regional S3 prefix list, not general internet connectivity.

## Validation and screenshots

1. Verify manager service health and memory, register three agents, and show manager-side Active status.
2. Add a harmless file in a dedicated test directory, alter it, and confirm a corresponding FIM event in real manager alerts.
3. Capture manager health/coverage and the real alert with timestamps and explanatory captions.
4. Rerun the focused data-ingress audit to show monitoring integration preserved the baseline.
5. Ask whether to keep or clean up all lab resources. Empty only the disposable staging prefix before deleting its bucket.

## Limits

This is a separate cloud manager, not a live connection to the VMware project. Manager-only telemetry is sufficient for this test; dashboard search and long-term index storage are not demonstrated. General vulnerability feed access and package patch repositories remain unavailable without a separately reviewed egress path.

References: https://documentation.wazuh.com/current/installation-guide/wazuh-server/index.html and https://documentation.wazuh.com/current/installation-guide/packages-list.html

## Live deployment evidence — 2026-10-05

Wazuh 4.14.8 manager and three agents were installed using signature-verified RPMs delivered through a private S3 gateway endpoint. Enrollment used a password and a manager certificate matching its private address. A controlled modification to `/opt/server-controls-fim/config.txt` on cloud-app produced real-time rule 550 (level 7), including before/after SHA-256 hashes. The JSON alert and screenshot are saved in evidence.

After enrollment, the six temporary port 1515 security-group rules were removed, manager enrollment was disabled, and enrollment-password files were removed. Port 1514 remains for authenticated agent telemetry. No public IP, SSH ingress, NAT gateway, dashboard, or indexer was added. This is a small lab deployment, not a production-sized SIEM or a compliance certification.
