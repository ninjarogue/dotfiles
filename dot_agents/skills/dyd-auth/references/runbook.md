# DYD Auth Runbook

Use this runbook for operation, cleanup, and rollback.

## Standard Commands

```bash
dyd-auth init
dyd-auth rotate
dyd-auth doctor dyd-codex
dyd-auth token dyd-codex
```

## Local Files Created

- `~/.config/dyd-auth/config`
- Secret Service keyring entry with attributes `app=dyd-auth` and `key=bws_access_token`
- `~/.config/bws/config`
- Optional legacy: `~/.config/bws/state/`
- Legacy plaintext paths (removed automatically on rotate):
  - `~/.config/bws/access-token`
  - `~/.config/bws/access-token.backups/`

## Security Scope

- `BWS_ACCESS_TOKEN` is a Bitwarden Secrets Manager machine-account token.
- It does not grant access to Password Manager personal vault contents.
- Access is limited to projects and secrets assigned to that machine account.
- Token storage uses the OS keyring (`secret-tool`) by default.
- Keep machine-account scope minimal and token expiration short.

## Cleanup Safety

- `bws-token-rotate --clear` only removes fixed legacy paths:
  - `~/.config/bws/access-token`
  - `~/.config/bws/access-token.backups/`

## Script-Only Uninstall

```bash
rm -f ~/.local/bin/dyd-auth
rm -f ~/.local/bin/bws-codex-setup
rm -f ~/.local/bin/bws-auth-token
rm -f ~/.local/bin/bws-token-rotate
hash -r
```

## Full Local Cleanup

```bash
rm -f ~/.local/bin/dyd-auth
rm -f ~/.local/bin/bws-codex-setup
rm -f ~/.local/bin/bws-auth-token
rm -f ~/.local/bin/bws-token-rotate
secret-tool clear app dyd-auth key bws_access_token || true
rm -rf ~/.config/dyd-auth
rm -f ~/.config/bws/access-token
rm -rf ~/.config/bws/access-token.backups
bws config server-base --delete || true
bws config state-opt-out --delete || true
rm -rf ~/.config/bws/state/*
hash -r
```

## Remote Bitwarden Cleanup Order

1. Revoke machine account access token(s).
2. Delete machine account.
3. Delete project secrets (`AUTH_*`).
4. Delete project.

## Recovery

- Expired BWS token: create new machine token in Bitwarden, run `dyd-auth rotate`.
- Missing BWS token: run `dyd-auth rotate`.
- Missing project secrets: create `AUTH_*` in Bitwarden project, run `dyd-auth doctor`.
