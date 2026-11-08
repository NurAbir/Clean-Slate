# Changelog

All notable changes to this project are documented here.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-11-08

### Added
- Initial release.
- Wipes saved passwords, cookies, sessions, and site storage for Chrome, Edge,
  Brave, Vivaldi (Chromium) and Firefox across all user profiles.
- Backup zip created before deletion (Desktop by default).
- Typed `WIPE` confirmation before any destructive action.
- `-DryRun` preview mode.
- `-Force` non-interactive mode (auto-closes running browsers).
- `-SkipBackup` opt-out.
- Live detection of running browsers with an offer to close them.

[1.0.0]: https://github.com/USERNAME/CleanSlate/releases/tag/v1.0.0
