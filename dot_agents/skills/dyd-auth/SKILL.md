---
name: dyd-auth
description: Operate and maintain the DYD auth token workflow backed by Bitwarden Secrets Manager. Use when users ask to set up token retrieval, fetch auth tokens, rotate BWS machine tokens, run DYD auth diagnostics, or uninstall and clean up DYD auth scripts and artifacts.
---

# DYD Auth

Use `dyd-auth` as the primary interface for this workflow.

## Workflow

1. Verify commands.
- Check `dyd-auth`, `bws`, `jq`, `curl`, and `secret-tool` are available.

2. Initialize config on first use.
```bash
dyd-auth init
```

3. Save or rotate machine access token.
```bash
dyd-auth rotate
```
- This stores token in the OS keyring (`secret-tool`, attributes `app=dyd-auth` and `key=bws_access_token`).
- This token scopes to Secrets Manager machine-account access only; it does not unlock personal `bw` vault data.

4. Validate readiness.
```bash
dyd-auth doctor dyd-codex
```
- Password grant expects `AUTH_CLIENT_ID`, `AUTH_USERNAME`, and `AUTH_PASSWORD` in the project.

5. Fetch auth token.
```bash
dyd-auth token dyd-codex
```

6. Re-run setup only when wiring changes are needed.
```bash
dyd-auth setup dyd-codex
```

## Troubleshooting

- If keyring token is missing: run `dyd-auth rotate`.
- If `bws` says server base is missing: run `bws config server-base https://vault.bitwarden.com` (or `https://vault.bitwarden.eu`).
- If secret create or edit fails with read-only access: create or update `AUTH_*` values in Bitwarden UI, then run `dyd-auth doctor`.

## Uninstall and Cleanup

Follow `references/runbook.md` for script-only uninstall, full local cleanup, and remote Bitwarden cleanup order.

## Maintenance Rule

Any script change under this workflow must update both:
- `~/.local/share/dyd-auth/README.md`
- This skill content (`SKILL.md` and references)

Validate before finishing changes:
```bash
bash -n ~/.local/bin/dyd-auth
bash -n ~/.local/bin/bws-codex-setup
bash -n ~/.local/bin/bws-auth-token
bash -n ~/.local/bin/bws-token-rotate
dyd-auth help
```
