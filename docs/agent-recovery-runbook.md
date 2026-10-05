# Agent coverage gap and recovery

Use this procedure only on the isolated lab. Systems Manager remains available when the Wazuh agent is stopped, allowing recovery without opening SSH.

1. Confirm the three expected names (`cloud-app`, `cloud-data`, `cloud-probe`) are Active in the manager's `agent_control -l` output.
2. Back up manager `ossec.conf`. For a short test, set `agents_disconnection_time` to `60s` in its global section and restart the manager. The normal threshold is 15 minutes; the shorter setting is temporary and can increase false positives.
3. Stop `wazuh-agent` on cloud-probe through Systems Manager. Keep the instance and Systems Manager agent running.
4. Read the manager's agent list until cloud-probe is Disconnected. Save timestamped output. This is a real coverage gap; file monitoring is unavailable on that host during the stop.
5. Start the agent, restore the original manager configuration, and restart the manager. Allow agents to reconnect.
6. Verify all three agents are Active. Never report recovery based only on a successful start command.

## Evidence

`recovery-baseline.json`, `recovery-disconnected.json`, and `recovery-restored.json` contain the live manager results. The screenshot report presents these saved outputs and is not a Wazuh dashboard. This test verifies manager status reporting; it does not claim delivery of an email, ticket, or external notification.

## Troubleshooting

If recovery fails, check the agent service and logs, existing enrollment key, manager service, and TCP 1514 rules. Do not reopen enrollment or reinstall the agent without diagnosing the failure. A manager restart can briefly show agents as Disconnected or Pending before the next handshake.
