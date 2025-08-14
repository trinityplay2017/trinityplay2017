@echo off

setlocal enableextensions
cd /d "C:\moxiang"
COLOR 1F
title MSO SERVER SETUP

:: ==================== Variables ====================
set "ROOT=C:\moxiang"
set "DLLPATH=%ROOT%\mx_dll"
set "DBPATH=%ROOT%\mx_db"
set "SERVERPATH=%ROOT%\mx_server"
set "SYS32=C:\Windows\System32"
set "SYSWOW64=C:\Windows\SysWOW64"
set "DLLS=DBTHREAD.dll INetwork.dll MHConsole.dll"

:: ==================== Check Admin ====================
echo Checking if run as administrator...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Failure: Please run this batch file as administrator.
    pause
    exit /b 1
)
echo Success: Administrative permissions confirmed.

:: ==================== Copy & Register DLLs ====================
call :CopyAndRegisterDLLs

:: ==================== Restore Databases ====================
call :RestoreDatabases

:: ==================== ODBC DSN ====================
call :RegisterODBC

:: ==================== Firewall Rules ====================
call :AddFirewallRules

echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U           Process Done           ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
pause
exit /b 0

:: ==================== Subroutines ====================

:CopyAndRegisterDLLs
echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U      Copying DLLs to System32    ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
for %%i in (%DLLS%) do (
    if exist "%DLLPATH%\%%i" (
        copy "%DLLPATH%\%%i" "%SYS32%" >nul
        if errorlevel 1 (echo Warning: Failed to copy %%i to %SYS32%) else (echo Copied %%i)
    ) else echo Warning: %%i not found in %DLLPATH%
)

echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U      Copying DLLs to SysWOW64    ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
for %%i in (%DLLS%) do (
    if exist "%DLLPATH%\%%i" (
        copy "%DLLPATH%\%%i" "%SYSWOW64%" >nul
        if errorlevel 1 (echo Warning: Failed to copy %%i to %SYSWOW64%) else (echo Copied %%i)
    ) else echo Warning: %%i not found in %DLLPATH%
)

echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U    Registering DLLs System32     ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
cd /d "%SYS32%"
for %%i in (%DLLS%) do (
    regsvr32.exe /s "%%i"
    if errorlevel 1 (echo Warning: Failed to register %%i) else (echo Registered %%i)
)

echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U    Registering DLLs SysWOW64     ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
cd /d "%SYSWOW64%"
for %%i in (%DLLS%) do (
    regsvr32.exe /s "%%i"
    if errorlevel 1 (echo Warning: Failed to register %%i) else (echo Registered %%i)
)
goto :eof

:RestoreDatabases
echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U      Executing / Restoring SQL   ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
sqlcmd -S .\SQLEXPRESS -E -i "%DBPATH%\MHLog.sql"
if errorlevel 1 (echo Warning: Failed to execute MHLog.sql) else (echo Executed MHLog.sql)
sqlcmd -S .\SQLEXPRESS -E -i "%DBPATH%\MHGame.sql"
if errorlevel 1 (echo Warning: Failed to execute MHGame.sql) else (echo Executed MHGame.sql)
sqlcmd -S .\SQLEXPRESS -E -i "%DBPATH%\MHCMember.sql"
if errorlevel 1 (echo Warning: Failed to execute MHCMember.sql) else (echo Executed MHCMember.sql)
goto :eof


:RegisterODBC
echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U        ODBC DSN Registration     ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
set cn=.
set host=%cn%\SQLEXPRESS
ODBCCONF CONFIGDSN "SQL Server" "DSN=MHCMEMBER|SERVER=%host%|Trusted_Connection=Yes|Database=MHCMEMBER"
ODBCCONF CONFIGDSN "SQL Server" "DSN=MHGAME|SERVER=%host%|Trusted_Connection=Yes|Database=MHGAME"
ODBCCONF CONFIGDSN "SQL Server" "DSN=MHLOG|SERVER=%host%|Trusted_Connection=Yes|Database=MHLOG"
echo  SYSTEM DSN created successfuly...

:AddFirewallRules
echo ¨X¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨[
echo ¨U        Firewall Inbound Rules    ¨U
echo ¨^¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨T¨a
:: Add Firewall Inbound Rule
netsh advfirewall firewall add rule name="AgentServer" dir=in program="c:\moxiang\mx_server\AgentServer.exe" action=allow
netsh advfirewall firewall add rule name="DistributeServer" dir=in program="c:\moxiang\mx_server\DistributeServer.exe" action=allow
echo  Firewall created successfuly...
