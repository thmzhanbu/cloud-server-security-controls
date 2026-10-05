# FIM investigation and troubleshooting

## Investigate a file change

Read the alert timestamp, agent, path, event type, detection mode, and before/after hashes. Check the approved change record or controlled-test context before treating the event as malicious. Preserve the original JSON and record the investigation decision.

In this lab, cloud-app's test file changed from 18 to 55 bytes and rule 550 reported a realtime checksum change. The operator deliberately appended a test line. Classification: authorized test activity, detection successful. No malware or compromise was established. The test file was disposable and removed with the instance during teardown.

## Diagnose missing alerts

Confirm agent service health and manager Active status, inspect agent logs for completed initial scan and realtime monitoring, verify the monitored path, then inspect manager alerts for the exact path. Check TCP 1514 policy and manager service before changing network access. No dashboard exists in this lab; use saved JSON or manager logs.

## Enrollment issue encountered

The default manager certificate did not match its private address and agent certificate verification failed. A manager certificate matching the private address resolved enrollment while retaining certificate verification. Shell-generated configuration also required correcting newline escaping before agents started. Both fixes were verified with live service checks and the eventual alert.

## Production improvements

Use redundant manager capacity, a managed certificate lifecycle, centralized alert storage, retention policies, tested notification integrations, patching, and continuous inventory. Indexer connector warnings are expected in this manager-only lab; they do not indicate an installed working indexer. The test demonstrates FIM and coverage status, not vulnerability-feed operation.
