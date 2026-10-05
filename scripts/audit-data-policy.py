"""Audit an AWS CLI rules export against a pinned expected application group."""
import argparse
import json
from datetime import datetime, timezone
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument('rules', type=Path)
p.add_argument('--app-group', required=True)
a = p.parse_args()
rows = json.loads(a.rules.read_text())['SecurityGroupRules']
findings = []
expected = 0
for r in rows:
    if r['IsEgress']:
        continue
    allowed = (r['IpProtocol'] == 'tcp' and r.get('FromPort') == 5432
               and r.get('ToPort') == 5432
               and r.get('ReferencedGroupInfo', {}).get('GroupId') == a.app_group)
    if allowed:
        expected += 1
    else:
        findings.append({'rule_id': r['SecurityGroupRuleId'], 'reason': 'Unexpected data ingress', 'rule': r})
if expected != 1:
    findings.append({'reason': 'Expected exactly one application-to-data TCP 5432 rule', 'count': expected})
print(json.dumps({'utc': datetime.now(timezone.utc).isoformat(), 'result': 'FAIL' if findings else 'PASS', 'findings': findings}, indent=2))
raise SystemExit(1 if findings else 0)
