:: Installed OS
@ECHO OFF
Set _Bitness=64
IF %PROCESSOR_ARCHITECTURE% == x86 (
  IF NOT DEFINED PROCESSOR_ARCHITEW6432 Set _Bitness=32
  )
Echo Operating System is %_Bitness% bit
pause