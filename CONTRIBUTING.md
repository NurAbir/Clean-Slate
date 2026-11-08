# Contributing to CleanSlate

Thanks for wanting to help! This is a small, focused tool, so a few guidelines
keep it that way.

## Ground rules

- **Safety first.** CleanSlate deletes user data. Any change must preserve the
  default backup + typed confirmation flow, and must not make the tool more
  destructive without an explicit opt-in flag.
- Keep it **dependency-free** and runnable on a stock Windows PowerShell 5.1.
- Match the existing style: 4-space indent, `Verb-Noun` function names,
  `Approved Verb` compliant, ASCII-only in `.ps1` files.

## Getting started

1. Fork and clone the repo.
2. Run a syntax check before committing:
   ```powershell
   $e=$null
   [void][System.Management.Automation.Language.Parser]::ParseFile(
       (Resolve-Path .\CleanSlate.ps1), [ref]$null, [ref]$e)
   if ($e) { $e | ForEach-Object { $_.Message } } else { 'SYNTAX OK' }
   ```
3. Manually test with `-DryRun` (never test a destructive change without a VM
   or a throwaway profile).

## Adding a browser

- Chromium-based browser? Add one entry to `$chromiumBrowsers` in `CleanSlate.ps1`
  with its `User Data` path. That's usually all it takes.
- Firefox-based? Follow the `$firefoxProfilesRoot` / `$firefoxTargets` pattern.

## Pull requests

- One logical change per PR.
- Update `README.md` and `CHANGELOG.md` when behavior changes.
- Describe how you tested (OS, browsers, `-DryRun` output).

## Reporting bugs

Open an issue using the bug report template and include your Windows version,
PowerShell version, affected browsers, and the exact command you ran.
