# Architecture decisions

- Sydney is the project's selected Region; all Regional resources stayed there.
- Four private subnets and security groups separate app, data, probe, and manager roles. There is no internet gateway, NAT gateway, public IP, or inbound SSH rule.
- Two private Systems Manager interface endpoints support administration. Their hourly cost persists even if instances are stopped.
- Three t3.micro nodes and one t3.small manager use encrypted gp3 volumes and required IMDSv2. Standard CPU credits avoid unlimited-mode surplus charges, with a throttling trade-off.
- A private S3 gateway endpoint permits package reads from the lab bucket only. Packages were checked against official SHA-512 files and RPM signatures. Temporary signed URLs were not committed.
- A separate cloud Wazuh manager avoids an untested VPN connection to the local VMware lab. No dashboard/indexer was provisioned.
- TCP 1514 remains for telemetry; password and certificate-verified enrollment on 1515 was temporary. Enrollment was disabled and password files removed afterward.
- One AZ reduces cost; redundancy, flow logs, automated patching, certificate rotation, and external notifications are future work, not demonstrated features.
- Controlled drift used a temporary probe-to-data ingress rule, removed after testing. The test stored no personal or payment data.
