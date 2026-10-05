# Stage-one cost estimate — 5 October 2026

Sydney prices retrieved through AWS Price List API. Three t3.micro Linux nodes: USD 0.0132000000/node-hour. Two interface endpoints in one AZ: USD 0.013/endpoint-hour. Three 8 GiB gp3 volumes: USD 0.096/GiB-month, using a 730-hour planning month. Baseline gp3 IOPS and throughput; no extra provisioned performance. Endpoint processing: USD 0.01/GB for the first tier.

| Runtime | Estimated USD, including 1 GB endpoint traffic |
|---|---:|
| 8 hours | 0.56 |
| 24 hours | 1.66 |
| 48 hours | 3.31 |
| 730 hours | 50.20 |

Estimate excludes taxes and future Wazuh integration, log storage, or package staging. No public IPv4 addresses or NAT gateways are planned. Actual charges depend on runtime, billing granularity, and usage. USD 10 is a planning target, not an automatic cutoff. Delete endpoints and volumes during teardown; stopping servers alone is insufficient.
