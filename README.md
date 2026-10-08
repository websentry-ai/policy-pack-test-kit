# Unbound Policy Packs test kit

This kit checks that your [Unbound Policy Packs](https://docs.getunbound.ai/playbook/policy-packs-testing-guide)
block or audit the commands they should. It sends 44 prompts, one per policy, to a real AI coding
agent and grades each result from your organization's Analytics.

## Safety

The infra CLIs the tests call (`aws`, `gcloud`, `az`, `kubectl`, `helm`, `terraform`, `docker`,
`psql`, `vault`, `gh`, `ssh`, `sudo`) are stubs that log their arguments and exit 0, and `curl` is
faked for the test host only. The other commands (`git`, `sed`, `rm`, `kill`, `env`, `cat`) are real
but harmless here: pushes go to a local folder, and the `/etc` tests are blocked or fail without root.
The agent gets a fake HOME with only its login, a copy of its account state without MCP servers or
projects, the Unbound hooks, and `~/.unbound`. It also gets a short allowlist of environment
variables, no MCP servers, and test projects in a temp folder, so your CLAUDE.md files don't load.
A Block test runs first, and the run stops unless Unbound denied it and nothing ran.

This is a test harness, not a security boundary. The agent runs as your user, with network access,
and `~/.unbound` (your Unbound Admin API key) is linked in because the hook needs it. Use a
disposable VM or container. The kit refuses to run as root.

## Requirements

- macOS or Linux with `python3` 3.8+ and `git`
- Claude Code, logged in (Cursor isn't supported yet)
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

- Each test agent gets a short system prompt (`SANDBOX_NOTE` in `kit.py`): it's in a sandbox with
  stub CLIs, it should run each command once as given, and it must not retry or work around a block.
  Without it, careful agents stop to ask before destructive-sounding commands. So the report measures
  policy enforcement, not whether an agent would attempt a command on its own.
- `report.md` includes agent output. Share it only with Unbound.
- Using Claude Code through Bedrock or Vertex? List the variables it needs in `UNBOUND_TEST_KEEP_ENV`.
  The agent's HOME is fake, so point credential files at absolute paths, e.g.
  `AWS_SHARED_CREDENTIALS_FILE=$HOME/.aws/credentials UNBOUND_TEST_KEEP_ENV=AWS_PROFILE,AWS_REGION,AWS_SHARED_CREDENTIALS_FILE ./run.sh ...`
- The sandbox is in `~/unbound-policy-test-work` (set `UNBOUND_TEST_WORK` to change it), and test
  projects are in your temp folder. `./setup.sh --force` clears both. Delete them when you're done.
- The five production-scoped rules (cloud destruction, deployment, kubectl apply, database admin,
  database writes) aren't covered yet.
- Send `report.md` to your Unbound contact with any questions.
