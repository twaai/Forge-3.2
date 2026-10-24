@echo off
setlocal EnableExtensions
set "ROOT=%~dp0"

where node.exe >nul 2>nul
if errorlevel 1 goto :node_missing

rem The embedded runtime carries its own undici, so the floor is the Node
rem security release 24.22.1, not the major alone: the 3.2.1 binary shipped a
rem runtime whose internal undici predates the CVE-2026-109869 fix.
set "NODE_NUM="
set "NODE_VER="
for /f "delims=" %%v in ('node -v') do set "NODE_VER=%%v"
for /f "tokens=1,2,3 delims=v." %%a in ('node -v') do set /a NODE_NUM=%%a*10000+%%b*100+%%c
if not defined NODE_NUM goto :node_unknown
if %NODE_NUM% LSS 242201 goto :node_old

if /I "%~1"=="--setup-only" goto :setup

pushd "%ROOT%"

if not exist "%ROOT%node_modules" (
    echo [FORGE 3.2] Installing Node dependencies...
    call npm install --no-fund --no-audit
    if errorlevel 1 goto :install_failed
)

echo [FORGE 3.2] Building...
call npm run build
if errorlevel 1 goto :build_failed

call node "%ROOT%dist\main.js" %*
set "CODE=%ERRORLEVEL%"
popd
exit /b %CODE%

:setup
pushd "%ROOT%"
call npm install --no-fund --no-audit
if errorlevel 1 goto :install_failed
call npm run build
set "CODE=%ERRORLEVEL%"
popd
if not "%CODE%"=="0" exit /b %CODE%
echo FORGE 3.2 setup verified
exit /b 0

:node_missing
echo [FORGE 3.2] Node.js was not found.
echo [FORGE 3.2] Install Node.js 24.22.1 or newer from https://nodejs.org/ and rerun forge.bat.
exit /b 1

:node_old
echo [FORGE 3.2] Node.js 24.22.1 or newer is required. Found: %NODE_VER%
echo [FORGE 3.2] Install a newer Node.js from https://nodejs.org/ and rerun forge.bat.
exit /b 1

:node_unknown
echo [FORGE 3.2] Could not read the Node.js version from "node -v".
echo [FORGE 3.2] Reinstall Node.js 24.22.1 or newer from https://nodejs.org/ and rerun forge.bat.
exit /b 1

:install_failed
echo [FORGE 3.2] npm install failed. Check the connection and rerun forge.bat.
exit /b 1

:build_failed
echo [FORGE 3.2] The TypeScript build failed. Fix the reported errors and rerun forge.bat.
exit /b 1
