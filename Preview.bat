@echo off
setlocal
title CleanSlate - Preview (dry run)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0CleanSlate.ps1" -DryRun
echo.
pause
