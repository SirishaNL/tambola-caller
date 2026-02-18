@echo off
cd /d "%~dp0"
set "LOGFILE=%~dp0run_log.txt"

echo Script started at %date% %time% > "%LOGFILE%"
echo Folder: %CD% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo PATH (first 500 chars): >> "%LOGFILE%"
echo %PATH:~0,500% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo Running: where flutter >> "%LOGFILE%"
where flutter >> "%LOGFILE%" 2>&1
echo. >> "%LOGFILE%"

echo Running: flutter --version >> "%LOGFILE%"
flutter --version >> "%LOGFILE%" 2>&1
echo Flutter exit code: %ERRORLEVEL% >> "%LOGFILE%"
echo. >> "%LOGFILE%"

echo Running: flutter run -d windows >> "%LOGFILE%"
flutter run -d windows >> "%LOGFILE%" 2>&1
echo App exit code: %ERRORLEVEL% >> "%LOGFILE%"

echo.
echo Finished. See run_log.txt in this folder.
start notepad "%LOGFILE%"
pause
