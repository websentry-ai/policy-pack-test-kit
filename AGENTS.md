# Instructions for AI agents running this kit

You are helping a person verify that Unbound's Policy Packs block or audit the right commands
from AI coding agents in their organization. This kit does the testing. Your job is to run it,
not to run the test commands yourself.

## Rules

1. **Do not run the test commands from `tests.json` in your own session.** `run.sh` sends each
   prompt to a fresh, separate agent inside a sandbox. Running them yourself would execute real
   commands (aws, kubectl, ssh, psql…) on this machine.
2. **Do not edit `tests.json`, the stubs, or `kit.py`.** Changed prompts invalidate the results.
3. **Do not add credentials, tokens or API keys anywhere.** The kit needs none beyond the
   existing `unbound-cli` login and the agent's own login.
4. **Ask the person** before steps marked 🧑. Do not do them on their behalf.
5. If a step fails, stop and show the person the error. Do not work around a failed safety check.

## Steps

1. **Check the machine.** Prefer a disposable VM or container. Confirm `python3`, `git` and
   `claude` (or `cursor-agent`) are installed, and that `unbound-cli --version` is 1.16 or newer.
2. **Check the organization.** Run `unbound-cli status` and show the person the
   `Organization` line. 🧑 Ask them to confirm it is the organization they want to test.
   If it is wrong or not logged in, 🧑 ask them to run `unbound-cli login`.
3. 🧑 **Ask the person to apply the Policy Packs** in the Unbound UI: Policies → Agentic Use →
   Policy Packs → apply each pack with its default Block/Audit settings. You cannot do this step.
4. **Build the sandbox:** `./setup.sh` (use `./setup.sh --force` to rebuild).
5. **Run the tests:** `./run.sh --org "<organization name from step 2>"`.
   It runs a Block test first and stops if it is not blocked. Expect about 15–25 minutes.
   Run it in the foreground or poll its output; do not start a second copy.
6. **Grade:** `./verify.sh`. It waits for Analytics, then writes `report.md`.
7. **Re-run once** any tests marked `NOT_RUN`: `./run.sh --org "<org>" --only <ids>`, then
   `./verify.sh` again. Results from all runs are merged.
8. **Report** to the person: the pass count, and every non-PASS row with its detail.
   The file to share with Unbound is `~/unbound-policy-test-work/report.md`.

## Result meanings

| Status | Meaning | What to do |
|---|---|---|
| `PASS` | Blocked or audited by the expected policy | Nothing |
| `WRONG_ACTION` | The policy matched, but a Block rule let the command run | Ask the person to set the rule to Block |
| `MISS` | Unbound saw the command but matched other policies | Report to Unbound |
| `RAN_NOT_RECORDED` | The command ran, but no Analytics row arrived | Re-run `./verify.sh` after a few minutes, then report |
| `NOT_RUN` | The test agent chose not to run the command | Re-run with `--only` |
