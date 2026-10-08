# Instructions for AI agents

You're helping someone check that Unbound's Policy Packs block or audit the right agent commands.
Run the kit. Don't run the test commands yourself.

## Rules

1. Don't run the commands in `tests.json`. `run.sh` sends each prompt to a separate agent in a
   sandbox. If you ran them here, they would really execute.
2. Don't edit `tests.json`, the stubs or `kit.py`. Changed prompts invalidate the results.
3. Don't add credentials, tokens or API keys anywhere. The kit only uses the existing
   `unbound-cli` and agent logins.
4. Don't change Unbound policies, packs or settings, with `unbound-cli` or the UI. Only the person does that.
5. Don't use sudo or run as root. Don't set `UNBOUND_TEST_WORK` or `UNBOUND_TEST_KEEP_ENV`, or use
   `--force`, without asking.
6. Steps marked **(ask)** need the person. Don't do them yourself.
7. If a step fails, stop and show the error. Never work around a failed safety check.

## Steps

1. Prefer a disposable VM or container. Check that `python3`, `git` and `claude` are installed,
   that `unbound-cli --version` is 1.16 or later, and that the person is an Admin in Unbound.
2. **(ask)** Run `unbound-cli status` and have the person confirm the `Organization` line is the
   one to test. If it isn't, they run `unbound-cli login`.
3. **(ask)** The person applies the Policy Packs in the Unbound UI (Policies → Agentic Use →
   Policy Packs), keeping each pack's default Block/Audit settings.
4. Run `./setup.sh` (add `--force` to rebuild).
5. Run `./run.sh --org "<org from step 2>" > run.log 2>&1 &` and poll `tail run.log`. It takes
   15 to 25 minutes, longer than most agent shell timeouts, and stops early if the first Block test
   isn't blocked. Don't start a second copy.
6. Run `./verify.sh`. It waits for Analytics, then writes `report.md`.
7. Re-run any `NOT_RUN` tests once with `./run.sh --org "<org>" --only <ids>`, then `./verify.sh`.
   Results from all runs are merged.
8. Tell the person the pass count and every non-PASS row. The report is
   `~/unbound-policy-test-work/report.md`. It includes agent output, so it goes only to Unbound.

## Results

| Status | Meaning | Next step |
|---|---|---|
| `PASS` | Blocked or audited by the expected policy | None |
| `WRONG_ACTION` | A Block test wasn't blocked, or an Audit test was | Ask the person to check the rule's action |
| `MISS` | Unbound saw the command but matched other policies | Report to Unbound |
| `RAN_NOT_RECORDED` | The command ran, but no Analytics row arrived | Run `./verify.sh` again in a few minutes, then report |
| `NOT_RUN` | The test agent didn't run the command | Re-run with `--only` |
| `NOT_TESTED` | The test was skipped (e.g. `/etc/example` exists) | Tell the person |
