@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0wsa.ps1" %*
exit /b %ERRORLEVEL%
