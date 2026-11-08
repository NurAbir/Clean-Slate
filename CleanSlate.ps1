<#
    CleanSlate.ps1  v1.0.0

    Wipes saved passwords, cookies, sessions and site storage for:
        Chrome, Edge, Brave, Vivaldi (Chromium) and Firefox
    across ALL profiles of the current Windows user.

    !!! DESTRUCTIVE - READ THIS !!!
    This permanently deletes browser credentials and login sessions.
    A backup zip is taken first and a typed confirmation is required, but
    there is NO UNDO unless you keep the backup.

    Usage:
        CleanSlate.bat                 (double-click: interactive wipe)
        CleanSlate.bat -DryRun         (preview only - changes nothing)
        powershell -ExecutionPolicy Bypass -File CleanSlate.ps1

    Flags:
        -DryRun       Show what would be deleted, then exit. Safe.
        -Force        No prompts. Also auto-closes running browsers.
        -SkipBackup   Do not create a backup zip (NOT recommended).
#>
[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Force,
    [switch]$SkipBackup
)

$ErrorActionPreference = 'Stop'
$ScriptVersion = '1.0.0'

# ==========================================================================
#  Config - edit here if you want to change scope
# ==========================================================================

# Also clear Local Storage / Session Storage. These often hold login tokens,
# so leaving this on logs you out of more sites but is a "deeper" wipe.
# Set to $false to only touch passwords, cookies and session files.
$IncludeSiteStorage = $true

# Where the backup zip is written (defaults to your Desktop).
$BackupRoot = [Environment]::GetFolderPath('Desktop')
if (-not $BackupRoot) { $BackupRoot = $env:USERPROFILE }

# ==========================================================================
#  Browser / target definitions
# ==========================================================================

$chromiumBrowsers = @(
    [pscustomobject]@{ Name = 'Chrome';  UserData = (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data') }
    [pscustomobject]@{ Name = 'Edge';    UserData = (Join-Path $env:LOCALAPPDATA 'Microsoft\Edge\User Data') }
    [pscustomobject]@{ Name = 'Brave';   UserData = (Join-Path $env:LOCALAPPDATA 'BraveSoftware\Brave-Browser\User Data') }
    [pscustomobject]@{ Name = 'Vivaldi'; UserData = (Join-Path $env:LOCALAPPDATA 'Vivaldi\User Data') }
)

$chromiumTargets = @(
    'Login Data'            # saved passwords
    'Login Data-journal'
    'Network\Cookies'       # cookies (modern layout)
    'Network\Cookies-journal'
    'Cookies'               # cookies (older layout)
    'Cookies-journal'
    'Sessions'              # session restore data
    'Current Session'
    'Current Tabs'
    'Last Session'
    'Last Tabs'
)
if ($IncludeSiteStorage) {
    $chromiumTargets += 'Local Storage'
    $chromiumTargets += 'Session Storage'
}

$firefoxProfilesRoot = Join-Path $env:APPDATA 'Mozilla\Firefox\Profiles'
$firefoxTargets = @(
    'logins.json'           # saved passwords
    'key4.db'               # password/key store
    'cookies.sqlite'        # cookies
    'cookies.sqlite-wal'
    'cookies.sqlite-shm'
    'sessionstore.jsonlz4'  # current session
    'sessionstore-backups'  # session backups
    'webappsstore.sqlite'
)
if ($IncludeSiteStorage) {
    $firefoxTargets += 'storage'   # site local storage
}

# ==========================================================================
#  Discovery
# ==========================================================================

function Get-ChromiumProfileDirs {
    param([string]$UserData)
    if (-not (Test-Path -LiteralPath $UserData)) { return @() }
    Get-ChildItem -LiteralPath $UserData -Directory -ErrorAction SilentlyContinue |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'Preferences') }
}

$plan = New-Object System.Collections.Generic.List[object]

foreach ($b in $chromiumBrowsers) {
    if (-not (Test-Path -LiteralPath $b.UserData)) { continue }
    foreach ($prof in (Get-ChromiumProfileDirs -UserData $b.UserData)) {
        foreach ($t in $chromiumTargets) {
            $src = Join-Path $prof.FullName $t
            if (Test-Path -LiteralPath $src) {
                $isDir = Test-Path -LiteralPath $src -PathType Container
                $plan.Add([pscustomobject]@{
                    Browser = $b.Name
                    Profile = $prof.Name
                    Source  = $src
                    RelPath = Join-Path (Join-Path $b.Name $prof.Name) $t
                    IsDir   = $isDir
                })
            }
        }
    }
}

if (Test-Path -LiteralPath $firefoxProfilesRoot) {
    foreach ($prof in (Get-ChildItem -LiteralPath $firefoxProfilesRoot -Directory -ErrorAction SilentlyContinue)) {
        foreach ($t in $firefoxTargets) {
            $src = Join-Path $prof.FullName $t
            if (Test-Path -LiteralPath $src) {
                $isDir = Test-Path -LiteralPath $src -PathType Container
                $plan.Add([pscustomobject]@{
                    Browser = 'Firefox'
                    Profile = $prof.Name
                    Source  = $src
                    RelPath = Join-Path (Join-Path 'Firefox' $prof.Name) $t
                    IsDir   = $isDir
                })
            }
        }
    }
}

function Write-PlanSummary {
    param($Plan, [string]$Heading)
    Write-Host ""
    Write-Host $Heading -ForegroundColor Yellow
    $Plan | Group-Object Browser | Sort-Object Name | ForEach-Object {
        $profiles = ($_.Group | Select-Object -ExpandProperty Profile -Unique) -join ', '
        Write-Host ("  {0,-8} {1,3} item(s)  [profiles: {2}]" -f $_.Name, $_.Count, $profiles)
    }
}

Write-Host ""
Write-Host "=== CleanSlate v$ScriptVersion ===" -ForegroundColor Cyan

if ($plan.Count -eq 0) {
    Write-Host "No browser data found. Nothing to do." -ForegroundColor Yellow
    return
}

if ($DryRun) {
    Write-PlanSummary -Plan $plan -Heading "DRY RUN - the following WOULD be deleted (nothing is touched):"
    Write-Host ""
    Write-Host "Dry run complete. Run CleanSlate.bat without -DryRun to actually wipe." -ForegroundColor Cyan
    return
}

# ==========================================================================
#  Close running browsers (files are locked while they run)
# ==========================================================================

$browserProcs = 'chrome','msedge','brave','vivaldi','firefox'
$running = Get-Process -Name $browserProcs -ErrorAction SilentlyContinue

if ($running) {
    $names = ($running | Select-Object -ExpandProperty ProcessName -Unique) -join ', '
    if ($Force) {
        Write-Host "Closing running browsers: $names" -ForegroundColor Yellow
        $running | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    } else {
        Write-Host "Running browsers detected: $names" -ForegroundColor Yellow
        $ans = Read-Host "Close them now so their files can be wiped? (y/N)"
        if ($ans -match '^[Yy]') {
            $running | Stop-Process -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        } else {
            Write-Host "Aborted. Close your browsers and run the tool again." -ForegroundColor Red
            return
        }
    }
}

# ==========================================================================
#  Show plan + confirm
# ==========================================================================

Write-PlanSummary -Plan $plan -Heading "The following will be permanently deleted:"

if (-not $Force) {
    Write-Host ""
    $confirm = Read-Host "Type WIPE to confirm (anything else cancels)"
    if ($confirm -cne 'WIPE') {
        Write-Host "Cancelled. Nothing was deleted." -ForegroundColor Yellow
        return
    }
}

# ==========================================================================
#  Backup
# ==========================================================================

$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$zipPath = $null

if (-not $SkipBackup) {
    Write-Host ""
    Write-Host "Creating backup..." -ForegroundColor Cyan
    $staging = Join-Path $env:TEMP "CleanSlate-$stamp"
    New-Item -ItemType Directory -Force -Path $staging | Out-Null

    foreach ($item in $plan) {
        $dest = Join-Path $staging $item.RelPath
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $dest) | Out-Null
        try {
            Copy-Item -LiteralPath $item.Source -Destination $dest -Recurse -Force -ErrorAction Stop
        } catch {
            Write-Host ("  ! could not back up {0}: {1}" -f $item.Source, $_.Exception.Message) -ForegroundColor DarkYellow
        }
    }

    $zipPath = Join-Path $BackupRoot "CleanSlate-Backup-$stamp.zip"
    if ((Get-ChildItem -LiteralPath $staging -Force -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0) {
        Compress-Archive -Path (Join-Path $staging '*') -DestinationPath $zipPath -Force
        Write-Host "Backup saved: $zipPath" -ForegroundColor Green
    } else {
        Write-Host "Nothing could be backed up (files may be locked). Continuing anyway." -ForegroundColor DarkYellow
    }
    Remove-Item -LiteralPath $staging -Recurse -Force -ErrorAction SilentlyContinue
}

# ==========================================================================
#  Delete
# ==========================================================================

Write-Host ""
Write-Host "Wiping..." -ForegroundColor Cyan
$deleted = 0
$failed = New-Object System.Collections.Generic.List[string]

foreach ($item in $plan) {
    try {
        Remove-Item -LiteralPath $item.Source -Recurse -Force -ErrorAction Stop
        $deleted++
    } catch {
        $failed.Add(("{0}  ->  {1}" -f $item.Source, $_.Exception.Message))
    }
}

Write-Host ""
Write-Host ("Done. Deleted {0} of {1} items." -f $deleted, $plan.Count) -ForegroundColor Green
if ($zipPath) { Write-Host ("Backup: {0}" -f $zipPath) -ForegroundColor Green }

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "Could not delete the following (a browser may still be running):" -ForegroundColor Red
    $failed | ForEach-Object { Write-Host ("  {0}" -f $_) }
}
