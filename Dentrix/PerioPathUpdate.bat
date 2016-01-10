@ECHO OFF
TITLE Perio Path Update
:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo You are not running updater as an admin.
	echo.
	echo Requesting administrative privileges. . .
	echo.
	pause
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:home
CLS
ECHO.
ECHO ================================
ECHO *                              *
ECHO *       Perio Path Update      *
ECHO *                              *
ECHO ================================
IF NOT EXIST C:\IS\DXUpdate mkdir C:\IS\DXUpdate
ROBOCOPY Y:\DXUpdate\Perio C:\IS\DXUpdate *.*
HKCUPerioPathUpdate.reg
HKUPerioPathUpdate.reg
RD /S C:\IS\DXUpdate
EXIT
