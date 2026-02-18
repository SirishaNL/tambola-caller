@echo off
REM Initialize repo, commit, and optionally create GitHub repo and push.
cd /d "%~dp0"

if not exist .git (
  echo Initializing git...
  git init
) else (
  echo Git already initialized.
)

echo.
echo Adding all files...
git add .

echo.
echo Creating initial commit...
git commit -m "Initial commit: Tambola Caller - Flutter app for Android and iOS"

if errorlevel 1 (
  echo No changes to commit, or commit failed. Check git status.
  goto :instructions
)

echo.
echo Checking for GitHub CLI (gh)...
where gh >nul 2>&1
if errorlevel 1 (
  goto :instructions
)

echo.
echo Create a new repo on GitHub and push? This will create a *private* repo by default.
echo Options: public repo add: --public
set /p CREATE="Create repo with 'gh'? (y/n): "
if /i not "%CREATE%"=="y" goto :instructions

gh repo create tambola-caller --private --source=. --remote=origin --push
if errorlevel 1 (
  echo.
  echo If repo already exists: git remote add origin https://github.com/YOUR_USERNAME/tambola-caller.git
  echo Then: git push -u origin main
  echo Or if your branch is master: git push -u origin master
)
goto :eof

:instructions
echo.
echo ===== MANUAL STEPS TO PUSH TO GITHUB =====
echo 1. Go to https://github.com/new
echo 2. Create a new repository (e.g. name: tambola-caller, leave "Initialize with README" UNCHECKED)
echo 3. Run these commands in this folder:
echo.
echo    git remote add origin https://github.com/YOUR_USERNAME/tambola-caller.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo Replace YOUR_USERNAME with your GitHub username.
echo ==========================================
:eof
