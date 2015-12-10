@ECHO OFF
TITLE Dentrix v8.0.5 Updater
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
ECHO * Dentrix v8.0.5 Update Script *
ECHO *                              *
ECHO ================================
ECHO.
ECHO 1) Run 64-bit Installer (Default)
ECHO 2) Run 32-bit Installer
ECHO 3) I don't know machine bits
ECHO.
ECHO 4) Hardware Installs/Drivers
ECHO.
ECHO 5) Exit Updater
ECHO.
SET /P install=Enter an Install Option: 
IF "%install%"=="1" goto x64installer
IF "%install%"=="2" goto x86installer
IF "%install%"=="3" goto bitscheck
IF "%install%"=="4" goto hardware
IF "%install%"=="5" exit

:bitscheck
Set _Bitness=64
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set _Bitness=32
  )
ECHO.
ECHO You are running a %_Bitness% bit machine. 
ECHO Press any key to begin the %_Bitness% bit installer.
ECHO.
PAUSE
IF /I "%_Bitness%" EQU "64" goto :x64installer
IF /I "%_Bitness%" EQU "32" goto :x86installer

:hardware
CLS
ECHO.
ECHO ================================
ECHO *                              *
ECHO *  Hardware Installs/Drivers   *
ECHO *                              *
ECHO ================================
ECHO.
ECHO 1) Old Acclaim IO Camera Drivers
ECHO 2) New Polaris IO Camera Drivers
ECHO 3) WOR Polaris IO Camera Drivers
ECHO 4) Hardware Installs/Drivers
ECHO.
ECHO 5) Go Back
ECHO.
SET /P hwinstall=Enter an Install Option: 
IF "%hwinstall%"=="1" GOTO BOSOldIO
IF "%hwinstall%"=="2" GOTO BOSNewIO
IF "%hwinstall%"=="3" GOTO WORIO
IF "%hwinstall%"=="4" GOTO hardware
IF "%hwinstall%"=="5" GOTO home

:x64installer
CLS
ECHO Performing pre-installation tasks
ECHO Please wait. . .

::Create Directories and Copy Files
IF NOT EXIST "C:\IS\DXUpdate" MKDIR C:\IS\DXUpdate
REM --> DXInstallSettings.ini needs to be copied locally
ROBOCOPY \\DX\dximage\DXUpdate\DX C:\IS\DXUpdate\DX x64DXInstallSettings.ini /E /R:1 /W:5 /TEE
REM --> DelProf script needs to be copied locally
ROBOCOPY \\DX\dximage\DXUpdate\Profile C:\IS\DXUpdate\Profile DelProf2.exe /E /R:1 /W:5 /TEE
REM --> Registry files need to be copied locally
ROBOCOPY \\DX\dximage\DXUpdate\Registry C:\IS\DXUpdate\Registry *x64*.reg /E /R:1 /W:5 /TEE
REM --> Check that Y:\ is connected
IF NOT EXIST Y:\ net use Y:\ \\dx\dximage /persistent:yes
ECHO Pre-installation tasks complete, beginning Dentrix Install

::Dentrix v.8.0 Uninstall
REM CLS
REM ECHO Removing old Dentrix versions
REM "C:\Program Files (x86)\InstallShield Installation Information\{43CA5C26-0F5F-47AD-987E-FDE8A4175FBF}\setup.exe" -runfromtemp -l0x0409  -removeonly

::Install SQL 2008 Client
REM CLS
REM ECHO Installing SQL 2008 Client Tools
REM ECHO.
REM ECHO Please wait. . .
REM CD /D Y:\DXUpdate\SQL
REM setup.exe /ConfigurationFile="Y:\DXUpdate\SQL\ConfigurationFile.ini"
REM CD /D C:\Windows\System32\
REM mmc.exe /32 C:\Windows\system32\SQLServerManager10.msc
REM CLS
REM ECHO Please confirm there is a Named Pipe for Dentrix:
REM ECHO SQL Native Client 10.0 Configuration > Aliases
REM PAUSE

::Dentrix Install
CLS
ECHO Dentrix will now perform a silent installation.
ECHO.
ECHO Please wait. . .
CD /D Y:\DXUpdate\DX\
setup.exe "/S:C:\IS\DXUpdate\DX\x64DXInstallSettings.ini"
CD C:\Program Files\DXONE\3rd Party Installs\LMAddin\lmadd\
DTX_LMAddIn.vsto

::DEXIS Update
CLS
ECHO Updating DEXIS Client
ECHO DO NOT restart the machine when the installation is complete.
ECHO.
ECHO Please wait. . .
CD /D Y:\DXUpdate\DEX\DEXInstall\Common\Software\
setup.exe
ECHO.
ECHO Updating DEXIS/Dentrix Integration
ECHO.
ECHO Please wait. . .
CD /D Y:\DXUpdate\DEX\DXIntegration\Engl-US\DentrixIntegrator\
DentrixIntegrator.exe
CLS
SET /P sirona=Do you need to install the Sirona integration (Worcester Panorex)? [Y/N]: 
IF /I "%sirona%"=="Y" goto SironaInstall
IF /I "%sirona%"=="N" goto FLV
:SironaInstall
CD /D Y:\DXUpdate\DEX\SironaIntegration
setup.exe

::Copy DEXIS FLV Files
:FLV
IF NOT EXIST "C:\Program Files (x86)\DEXIS\FlashDir" MKDIR "C:\Program Files (x86)\DEXIS\FlashDir"
ROBOCOPY "\\dx\dximage\Dexis Calibration Files\Files" "C:\Program Files (x86)\DEXIS\FlashDir" *.* /E /R:1 /W:5 /TEE

::Apply Default Registry Settings
CLS
ECHO.
ECHO ================================
ECHO *                              *
ECHO * Default User Registry Update *
ECHO *                              *
ECHO ================================
ECHO.
ECHO 1) Boston
ECHO 2) Worcester 
ECHO.
SET /P x64rupdate=Select an update based on the location of this machine: 
IF "%x64rupdate%"=="1" goto x64BOS
IF "%x64rupdate%"=="2" goto x64WOR

:x64BOS
ECHO Loading Boston default registry
ECHO There are two registry additions, click "Yes" on all prompts.
CD /D C:\Windows\System32
REG LOAD HKU\halford C:\Users\Default\NTUSER.dat
CD /D C:\IS\DXUpdate\Registry
x64HKLMRegistryWinter2015.reg
Autox64HKUBostonRegistryWinter2015.reg
PAUSE
REG UNLOAD HKU\halford
ROBOCOPY \\dx\dximage\DXUpdate\Registry\Restore\BOS\x64 C:\Users\Public\Desktop *.lnk /E /R:1 /W:5
GOTO :x64ROP
:x64WOR
ECHO Loading Worcester default registry
ECHO There are two registry additions, click "Yes" on all prompts.
CD /D C:\Windows\System32
REG LOAD HKU\halford C:\Users\Default\NTUSER.dat
CD /D C:\IS\DXUpdate\Registry
x64HKLMRegistryWinter2015.reg
Autox64HKUWorcesterRegistryWinter2015.reg
PAUSE
REG UNLOAD HKU\halford
ROBOCOPY \\dx\dximage\DXUpdate\Registry\Restore\WOR\x64 C:\Users\Public\Desktop *.lnk /E /R:1 /W:5
GOTO :x64ROP

::Remove Old Profiles
:x64ROP
CLS
CD /D C:\IS\DXUpdate\Profile
delprof2.exe /l /ed:admin* /ed:support
set /P c=Is the above list of users OK to delete [Y/N]?
if /I "%c%" EQU "Y" goto :x64ProfDelOK
if /I "%c%" EQU "N" goto :x64ProfDelNotOK
:x64ProfDelOK
delprof2.exe /ed:admin* /ed:support
GOTO :x64SU
:x64ProfDelNotOK
ECHO No profiles will be deleted, please run the profile delete
ECHO script manually from \DX\dximage\DXUpdate\Profile
ECHO.
ECHO Script will now install software updates.
PAUSE
GOTO :x64SU

::Software Updates
:x64SU
CLS
ECHO Updating ancillary system software
CD /D Y:\DXUpdate\Software
ePadUIv12.exe
ePadDesktopv12.exe

::Post Installation Tasks
CLS
ECHO Installation is complete. Post install clean-up will begin.
CD /D C:\
DEL C:\Users\Default\Desktop\*.dotx
DEL C:\Users\Public\Desktop\*.dotx
DEL C:\Users\Public\Desktop\Dentrix*.lnk
ROBOCOPY Y:\DXUpdate\Docs C:\Users\Public\Desktop *.dotx /E /R:1 /W:5 /TEE
ECHO The local install file directory will now be deleted.
PAUSE
RD /S C:\IS\DXUpdate
GOTO :END

:x86installer




:END
CLS
ECHO Installation is complete.
ECHO.
ECHO Machine will now reboot.
shutdown /r /t 0 /d p:4:1