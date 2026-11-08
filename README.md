# CleanSlate

**One-click wipe of saved browser passwords, cookies, and sessions on Windows.**

CleanSlate removes the local credentials and login state stored by your browsers —
so the next person on the machine finds a clean slate and every site logs you out.

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg)
![PowerShell 5.1+](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE.svg)
![Status: stable](https://img.shields.io/badge/status-stable-brightgreen.svg)

> ⚠️ **DESTRUCTIVE TOOL — READ BEFORE USE.** CleanSlate **permanently deletes**
> saved passwords and login sessions. There is **no undo** beyond the backup zip
> it makes before wiping. Use it only on machines and accounts you own or are
> authorized to wipe. Provided **as is**, with **no warranty** (see [License](#license)).

---

## Why

Sometimes you just need everything gone, fast:

- Selling, lending, or handing a PC to someone else.
- Using a shared/library/public computer and want to leave no trace.
- Debugging a stubborn "wrong account" or login-loop problem.
- Panic button before stepping away from a machine.

Doing this by hand across profiles and browsers is slow and error-prone.
CleanSlate finds every browser profile and clears the right files in one run.

## What it does

For **Chrome, Edge, Brave, Vivaldi** (all Chromium-based) and **Firefox**, across
**all profiles** of the current Windows user, it deletes:

| Data | Chromium files | Firefox files |
| --- | --- | --- |
| Saved passwords | `Login Data`, `Login Data-journal` | `logins.json`, `key4.db` |
| Cookies | `Cookies`, `Network\Cookies`, `*-journal` | `cookies.sqlite`, `cookies.sqlite-wal/shm` |
| Sessions / open tabs | `Sessions\`, `Current/Last Session`, `Current/Last Tabs` | `sessionstore.jsonlz4`, `sessionstore-backups\` |
| Site storage *(optional)* | `Local Storage\`, `Session Storage\` | `storage\`, `webappsstore.sqlite` |

Site storage often holds auth tokens, so clearing it logs you out of more sites.
It is **on by default**; flip `$IncludeSiteStorage` to `$false` in `CleanSlate.ps1`
to wipe only passwords, cookies, and session files.

## Safety features

- **Backup first** — writes `CleanSlate-Backup-<timestamp>.zip` to your Desktop before deleting.
- **Typed confirmation** — you must type `WIPE`; anything else cancels.
- **Preview mode** — `-DryRun` shows exactly what would be deleted and changes nothing.
- **Process aware** — detects running browsers and offers to close them (locking files
  is the #1 reason a wipe silently fails).
- **No system changes** — does *not* touch Windows Credential Manager, Wi-Fi, RDP,
  or anything outside the browser profile folders.

## Requirements

- Windows 10 or 11
- Windows PowerShell 5.1 (built in) or PowerShell 7+
- No dependencies, no install, no admin rights (it only touches the current user's data)

## Usage

1. **Download / clone** this repo.
2. **Preview first** (recommended): double-click **`Preview.bat`**, or run:
   ```powershell
   powershell -ExecutionPolicy Bypass -File .\CleanSlate.ps1 -DryRun
   ```
3. **Wipe**: double-click **`CleanSlate.bat`** and follow the prompts:
   - Close browsers? → `y`
   - Type `WIPE` to confirm.
4. Keep the backup zip if you might want to restore.

### Command line

```powershell
# Interactive wipe (same as double-clicking CleanSlate.bat)
powershell -ExecutionPolicy Bypass -File .\CleanSlate.ps1

# Preview only, changes nothing
powershell -ExecutionPolicy Bypass -File .\CleanSlate.ps1 -DryRun

# Unattended: no prompts, auto-closes browsers
powershell -ExecutionPolicy Bypass -File .\CleanSlate.ps1 -Force

# Skip the backup zip (NOT recommended)
powershell -ExecutionPolicy Bypass -File .\CleanSlate.ps1 -SkipBackup
```

| Flag | Effect |
| --- | --- |
| `-DryRun` | Show what would be deleted, then exit. Nothing is touched. |
| `-Force` | No prompts. Also auto-closes running browsers. |
| `-SkipBackup` | Do not create a backup zip. |

## Restoring from a backup

The backup zip mirrors your profile layout, e.g.:

```
Chrome/Profile 1/Login Data
Firefox/xxxx.default-release/cookies.sqlite
```

To restore, close the browser, unzip, and copy each file back into the matching
profile folder (Chromium: `%LOCALAPPDATA%\<Vendor>\...\User Data\`;
Firefox: `%APPDATA%\Mozilla\Firefox\Profiles\`), overwriting what's there.

> Note: Chromium encrypts saved passwords with the Windows user account (DPAPI).
> A backup restored to the **same Windows user** decrypts fine; restoring to a
> different user or machine will not.

## FAQ

**Does it wipe passwords in my browser's cloud/sync account?**
No. CleanSlate only touches local files. If you're signed into browser sync,
passwords may sync back down. To be thorough, sign out of browser sync first
(or turn sync off in the browser settings).

**Will it log me out of everything?**
Yes — cookies and session storage are what keep you logged in. Expect to sign in
again everywhere.

**Why is `-Force` closing my browsers?**
Browser databases are locked while the app runs, so the wipe would fail. `-Force`
closes them for you. Save your work first.

**Antivirus / SmartScreen flagged it. Is that normal?**
Possibly. A script that reads/deletes browser credential stores and terminates
browser processes can look suspicious to heuristics. The source is right here to
audit; run it from a clone you trust rather than a random download.

**It didn't delete some files.**
A browser was probably still running (or a service like Edge background mode was).
Fully exit all browsers and run again. Remaining files are listed on failure.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Bug reports and PRs welcome.

## License

[MIT](LICENSE) © 2026 Nur Abir.

CleanSlate is not affiliated with, endorsed by, or sponsored by Google, Microsoft,
Brave, Vivaldi, or Mozilla. All trademarks belong to their respective owners.

**Use at your own risk.** The authors are not responsible for lost data, lost
passwords, or any damage resulting from use of this tool.
