# Unbound Policy Packs test kit

Checks that the [Unbound Policy Packs](https://docs.getunbound.ai/playbook/policy-packs-testing-guide)
block or audit what they should, using a real AI coding agent, and grades the results for you.

It runs 44 prompts, one per policy, each in a fresh headless agent session, then reads your
organization's Analytics and writes a pass/fail report.

## Safe by design

- **Nothing real runs.** `aws`, `gcloud`, `az`, `kubectl`, `helm`, `terraform`, `docker`, `psql`,
  `vault`, `gh`, `ssh` and `sudo` are stubs that print what they were asked to do and exit 0.
  `curl` is faked only for the test's placeholder host (`export.example.com`).
- **The agent can't see your credentials.** It runs with a separate HOME (linked only to the
  agent's and Unbound's own config), and cloud, Kubernetes, database, Vault, GitHub and
  SSH-agent environment variables are removed.
- **Each test gets its own throwaway project**, with a local git remote, so git pushes go nowhere.
- **Fails closed.** A Block test runs first; if it isn't blocked, the run stops before any Audit test.

We still recommend a disposable VM or container.

## Requirements

- macOS or Linux with `python3` (3.8+) and `git`
- Claude Code (`claude`), logged in. Cursor (`cursor-agent`) support is experimental.
- `unbound-cli` 1.16+, logged in to the organization you want to test, with an Admin role
  (`npm install -g unbound-cli && unbound-cli login && unbound-cli onboard`)
- The Policy Packs applied in that organization: **Policies → Agentic Use → Policy Packs**

## Run it

```bash
git clone https://github.com/websentry-ai/policy-pack-test-kit && cd policy-pack-test-kit
./setup.sh
./run.sh --org "Your Org Name"      # exactly as `unbound-cli status` shows it; ~15–25 min
./verify.sh                         # writes ~/unbound-policy-test-work/report.md
```

Re-run tests the agent skipped: `./run.sh --org "Your Org Name" --only DB2,SY2` and `./verify.sh` again.

**Using your own AI agent?** Point it at this folder and say: *"Follow AGENTS.md."*

## Notes

- Each test agent is told the truth about where it is: a disposable sandbox whose infra CLIs are
  stubs. Without that, careful agents stop to ask before anything that sounds destructive, and the
  command never reaches the policy. The note also tells the agent not to retry or work around a block.

- If Claude Code reaches Anthropic through Bedrock or Vertex, pass the variables it needs:
  `UNBOUND_TEST_KEEP_ENV=AWS_PROFILE,AWS_REGION ./run.sh …`
- The sandbox lives in `~/unbound-policy-test-work` (override with `UNBOUND_TEST_WORK`).
  Delete it when you're done.
- Five production-scoped rules (production cloud destruction, deployment, kubectl apply,
  database admin and database writes) aren't covered yet.
- Questions or unexpected results: send `report.md` to your Unbound contact.
