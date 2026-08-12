@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0windows-admin.ps1" %*
exit /b %ERRORLEVEL%
