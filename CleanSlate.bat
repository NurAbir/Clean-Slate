@echo off
setlocal
title CleanSlate - Browser Wipe
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0CleanSlate.ps1" %*
echo.
pause
