# Instructions for AI agents

You help a person test Unbound Policy Packs. Run the kit. Do not run the test commands yourself.

## Rules

1. Do not run the commands in `tests.json`. `run.sh` gives each prompt to a different agent in a
   sandbox. If you run them here, they really run.
2. Do not edit `tests.json`, the stubs or `kit.py`. Changed prompts make the results incorrect.
3. Do not add credentials, tokens or API keys. The kit uses only the `unbound-cli` and Claude Code logins.
4. Do not change Unbound policies, packs or settings. Only the person does this.
5. Do not use sudo or run as root. Ask the person before you set `UNBOUND_TEST_WORK` or
   `UNBOUND_TEST_KEEP_ENV`, or use `--force`.
6. Steps with **(ask)** need the person. Do not do them yourself.
7. If a step fails, stop and show the error. Do not try to go around a safety check.

## Steps

1. Make sure that this is a VM or a container that the person can discard. Make sure that `python3`,
   `git` and `claude` are installed, and that `unbound-cli --version` is 1.16 or later.
2. **(ask)** Run `unbound-cli status`. The person confirms the `Organization` line and the Admin role.
3. **(ask)** The person applies the Policy Packs to a user group that has only the tester. The rule
   `Block git push to main or master` must be Block or Warn. `run.sh` checks this.
4. **(ask)** The person tells their security team about the test.
5. Run `./setup.sh`. If the sandbox exists, ask the person before you use `./setup.sh --force`.
6. Run `./run.sh --org "<org from step 2>" > run.log 2>&1 &`. Read `tail run.log` until it is done.
   It takes 30 to 60 minutes. Do not start a second copy. If it stops and lists other users, show
   the list to the person. **(ask)** Add `--yes` only if the person agrees.
7. Run `./verify.sh`. It waits for Analytics and then writes `report.md`.
8. If tests show `NOT_RUN`, run `./run.sh --org "<org>" --only <ids>` one time, then `./verify.sh`.
   `verify.sh` uses the last attempt of each test that ran.
9. Tell the person the pass count and each row that is not `PASS`. The report is
   `~/unbound-policy-test-work/report.md`. It has agent output. The person sends it to Unbound.
10. **(ask)** When the person is done, run `./cleanup.sh`.

## Results

| Status | Meaning | Next step |
|---|---|---|
| `PASS` | The expected policy matched and did its action | None |
| `WRONG_ACTION` | The policy matched, but did not block or audit as the pack sets | Show the detail to the person |
| `MISS` | Unbound saw the command, but other policies matched | Tell the person to send the report to Unbound |
| `RAN_NOT_RECORDED` | No Analytics row yet | Run `./verify.sh --settle 0` again later |
| `NOT_RUN` | The test agent did not run the command | Run again with `--only` |
| `NOT_TESTED` | The kit skipped the test (for example, `/etc/example` exists) | Tell the person |
