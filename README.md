# Unbound Policy Packs test kit

This kit checks that your [Unbound Policy Packs](https://docs.getunbound.ai/playbook/policy-packs-testing-guide)
block or audit the commands they should. It sends 44 prompts, one per policy, to a real AI coding
agent and grades each result from your organization's Analytics.

## Safety

Nothing real runs. The CLIs the tests use (`aws`, `gcloud`, `az`, `kubectl`, `helm`, `terraform`,
`docker`, `psql`, `vault`, `gh`, `ssh`, `sudo`) are stubs that print their arguments and exit 0,
and `curl` is faked for the test host only. The agent gets a separate HOME and no cloud, database,
Vault, GitHub or SSH-agent variables. Each test has its own project with a local git remote.
A Block test runs first, and the run stops if it isn't blocked.

A disposable VM or container is still the safest place to run it.

## Requirements

- macOS or Linux with `python3` 3.8+ and `git`
- Claude Code, logged in (Cursor support is experimental)
- `unbound-cli` 1.16+ with hooks installed (`unbound-cli login && unbound-cli onboard`),
  as an Admin of the organization you're testing
- The Policy Packs applied in that organization (Policies → Agentic Use → Policy Packs)

## Run it

```bash
git clone https://github.com/websentry-ai/policy-pack-test-kit && cd policy-pack-test-kit
./setup.sh
./run.sh --org "Your Org Name"   # as shown by `unbound-cli status`; takes 15 to 25 min
./verify.sh                      # writes ~/unbound-policy-test-work/report.md
```

To re-run tests the agent skipped: `./run.sh --org "Your Org Name" --only DB2,SY2`, then `./verify.sh`.

If an AI agent is running this for you, ask it to follow `AGENTS.md`.

## Notes

- Each test agent is told it's in a sandbox with stub CLIs, and not to retry or work around a block.
  Without that note, careful agents stop to ask before destructive-sounding commands, and the
  policy never sees them.
- Using Claude Code through Bedrock or Vertex? Keep the variables it needs:
  `UNBOUND_TEST_KEEP_ENV=AWS_PROFILE,AWS_REGION ./run.sh ...`
- The sandbox is in `~/unbound-policy-test-work` (set `UNBOUND_TEST_WORK` to change it). Delete it when you're done.
- The five production-scoped rules (cloud destruction, deployment, kubectl apply, database admin,
  database writes) aren't covered yet.
- Send `report.md` to your Unbound contact with any questions.
