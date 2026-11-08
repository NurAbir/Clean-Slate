# Security Policy

## About this tool

CleanSlate is a **local, offline** Windows utility. It has no network features,
no telemetry, and no dependencies. It reads and deletes files inside the current
user's own browser profile folders and reports results to the console.

## Intended use

- Run it only on machines and accounts **you own or are authorized to manage**.
- It is designed to help *you* remove *your own* locally stored browser secrets.

## Reporting a vulnerability

If you find a security problem — for example, the tool deletes something outside
its documented scope, escapes the user's profile directories, or can be made to
run untrusted input — please report it **privately**:

- Open a [GitHub Security Advisory](../../security/advisories/new) (preferred), or
- Contact the maintainer directly.

Please **do not** open a public issue for security problems. Include:

- A description and the impact.
- Steps to reproduce.
- Affected version and Windows/PowerShell version.

You can expect an acknowledgement within a few days.

## Scope

In scope:
- Unintended data deletion beyond the documented targets.
- Path-handling bugs (traversal, symlink/junction escapes).
- Command-injection or argument-injection in the `.ps1` / `.bat` files.

Out of scope:
- The tool doing exactly what it documents (deleting browser credentials).
- Antivirus/SmartScreen heuristics flagging the scripts.
- Data loss when the user runs with `-SkipBackup` or ignores the backup.
