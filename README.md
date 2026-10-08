# Unbound Policy Packs test kit

This kit tests your [Unbound Policy Packs](https://docs.getunbound.ai/playbook/policy-packs-testing-guide).
It gives 44 prompts, one for each policy, to Claude Code. Then it reads your Unbound Analytics and
writes a report. Unbound Security maintains this kit. `websentry-ai` is the GitHub organization of Unbound.

## Before you start

- Use a VM or a container that you can discard. The test agent runs real shell commands.
- Apply the packs to a user group that has only the tester. Packs apply to their users immediately.
- Tell your security team before you start. Some test commands look like attacks, for example `ssh root@host`.
- Get these tools: Python 3.8 or later, `git`, Claude Code (logged in), and `unbound-cli` 1.16 or later
  (`unbound-cli login && unbound-cli onboard`). The tester must have the Admin role.
- The test takes 30 to 60 minutes. It starts 45 short Claude Code sessions with your Claude account.

## Run the test

```bash
git clone --branch v0.3.0 https://github.com/websentry-ai/policy-pack-test-kit
cd policy-pack-test-kit
./setup.sh
./run.sh --org "Your Org Name"
./verify.sh
```

Use the organization name that `unbound-cli status` shows. `verify.sh` writes
`~/unbound-policy-test-work/report.md`. To do a test again, use `./run.sh --org "Your Org Name" --only DB2,SY2`
and then `./verify.sh`. To let an AI agent do the test, tell it to follow `AGENTS.md`.

## What the kit does

- It replaces these CLIs with stubs that only record their arguments: `aws`, `gcloud`, `az`, `kubectl`,
  `helm`, `terraform`, `docker`, `psql`, `vault`, `gh`, `ssh`, `sudo` and `unbound-cli`. A curl to the test
  host is also a stub.
- `git`, `sed`, `rm`, `kill`, `env` and `cat` are real. They change only the test folders. `git push`
  goes to a local folder. The `/etc` tests cannot change files because the kit does not run as root.
- Before each run, it makes sure that a Block policy stops the first test. If not, it stops.
- It reads Unbound data with `unbound-cli` only. It does not change your policies.

## What the test agent can get to

This kit is a test tool, not a security boundary. The agent runs as your user and has network access.
It gets your Claude Code login, the Unbound hooks and `~/.unbound` (your Unbound API key). On macOS, it
also gets your keychains, because Claude Code keeps its login there. It does not get your other
environment variables, MCP servers or CLAUDE.md files.

Data goes to the same places as in usual work: prompts go to Anthropic, and commands go to Unbound.
The report stays on your machine.

## Results

| Result | Meaning |
|---|---|
| `PASS` | The expected policy matched and did its action. |
| `WRONG_ACTION` | The policy matched, but did not block or audit as the pack sets. |
| `MISS` | Unbound saw the command, but other policies matched. |
| `RAN_NOT_RECORDED` | No Analytics row yet. Audit rows can take hours when Unbound is busy. Run `./verify.sh --settle 0` again later. |
| `NOT_RUN` | The agent did not run the command. Do the test again with `--only`. |

The report has your organization name, your email and the agent output. Send it to your Unbound contact
or to support@unboundsecurity.ai.

## Clean up

Run `./cleanup.sh`. It deletes `~/unbound-policy-test-work`. The test rows stay in Unbound Analytics.

## Notes

- Each test agent gets a short system prompt (`SANDBOX_NOTE` in `kit.py`). It tells the agent that the
  CLIs are stubs and to run each command once. Thus the report measures the policies, not the agent.
- With Claude Code on Bedrock or Vertex, list the variables that it needs in `UNBOUND_TEST_KEEP_ENV`.
  Use credentials only for the model, not for other cloud resources.
- The packs also have five production rules that the kit does not test: cloud destruction, deployment,
  kubectl apply, database admin and database writes.
