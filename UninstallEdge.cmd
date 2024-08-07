@echo off
:: Bye Bye Edge OneCMD Edition ::
:: Made by Useful Stuffs ::
:: Credits: ShadowWhisperer for his uninstall Edge script (some code took) ::
:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 rem this works also from cmd shell, other than %~0
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO.
  ECHO **************************************
  ECHO Invoking UAC for Privilege Escalation
  ECHO **************************************

  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

:main
echo Checking system...
if exist "%ProgramFiles%\Microsoft\Edge" goto uninstall32
if exist "%ProgramFiles(x86)%\Microsoft\Edge" goto uninstall64
goto noedge

:uninstall32
echo Edge was found!
echo Closing Edge...
taskkill /f /t /im msedge.exe > nul
taskkill /f /t /im MicrosoftEdgeUpdate.exe > nul
taskkill /f /t /im msedgewebview2.exe > nul
echo Uninstalling Edge...
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f > nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f > nul
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView" /f > nul
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /f > nul
net stop MicrosoftEdgeElevationService > nul
sc delete MicrosoftEdgeElevationService > nul
net stop edgeupdate > nul
sc delete edgeupdate > nul
net stop edgeupdatem > nul
sc delete edgeupdatem > nul
rd /s /q "%ProgramData%\Microsoft\EdgeUpdate" > nul
rd /s /q "%ProgramFiles%\Microsoft\Edge" > nul
rd /s /q "%ProgramFiles%\Microsoft\EdgeCore" > nul
rd /s /q "%ProgramFiles%\Microsoft\EdgeUpdate" > nul
rd /s /q "%ProgramFiles%\Microsoft\EdgeWebView" > nul
rd /s /q "%ProgramFiles%\Microsoft\Temp" > nul
del /f /q "%userprofile%\Desktop\Microsoft Edge.lnk" > nul
del /f /q "%systemdrive%\Users\Public\Desktop\Microsoft Edge.lnk" > nul
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > nul
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > nul
del /f /q "%appdata%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk" > nul
reg add "HKLM\Software\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f > nul
for /f %f in ('dir /s /b %SystemRoot%\System32\Tasks\*MicrosoftEdge*') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
for /f "delims=" %%a in ('powershell "(New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -AllUsers ^| Where-Object { $_.PackageFullName -like '*microsoftedge*' } ^| Select-Object -ExpandProperty PackageFullName"') do (
    if not "%%a"=="" (
        set "APP=%%a"
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\!USER_SID!\!APP!" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\!APP!" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\!APP!" /f >nul 2>&1
        powershell -Command "Remove-AppxPackage -Package '!APP!'" 2>nul
        powershell -Command "Remove-AppxPackage -Package '!APP!' -AllUsers" 2>nul
    )
)
for /f %f in ('dir /s /b %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
for /f %f in ('dir /s /b %SystemRoot%\System32\MicrosoftEdge*.exe') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
echo Microsoft Edge should be now uninstalled.
echo Please reboot Windows.
pause
goto eof

:uninstall64
echo Edge was found!
echo Closing Edge...
taskkill /f /t /im msedge.exe > nul
taskkill /f /t /im MicrosoftEdgeUpdate.exe > nul
taskkill /f /t /im msedgewebview2.exe > nul
echo Uninstalling Edge...
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft Edge Update" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Microsoft EdgeWebView" /f > nul
reg delete "HKLM\SOFTWARE\Microsoft\Active Setup\Installed Components\{9459C573-B17A-45AE-9F64-1857B5D58CEE}" /f > nul
reg delete "HKLM\SOFTWARE\WOW6432Node\Microsoft\EdgeUpdate" /f > nul
net stop MicrosoftEdgeElevationService > nul
sc delete MicrosoftEdgeElevationService > nul
net stop edgeupdate > nul
sc delete edgeupdate > nul
net stop edgeupdatem > nul
sc delete edgeupdatem > nul
rd /s /q "%ProgramData%\Microsoft\EdgeUpdate" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\Edge" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeCore" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeUpdate" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\EdgeWebView" > nul
rd /s /q "%ProgramFiles(x86)%\Microsoft\Temp" > nul
del /f /q "%userprofile%\Desktop\Microsoft Edge.lnk" > nul
del /f /q "%systemdrive%\Users\Public\Desktop\Microsoft Edge.lnk" > nul
del /f /q "%ProgramData%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > nul
del /f /q "%appdata%\Microsoft\Windows\Start Menu\Programs\Microsoft Edge.lnk" > nul
del /f /q "%appdata%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar\Microsoft Edge.lnk" > nul
reg add "HKLM\Software\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f > nul
reg add "HKLM\Software\WOW6432Node\Microsoft\EdgeUpdate" /v "DoNotUpdateToEdgeWithChromium" /t REG_DWORD /d 1 /f > nul
for /f %f in ('dir /s /b %SystemRoot%\System32\Tasks\*MicrosoftEdge*') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
for /f "delims=" %%a in ('powershell "(New-Object System.Security.Principal.NTAccount($env:USERNAME)).Translate([System.Security.Principal.SecurityIdentifier]).Value"') do set "USER_SID=%%a"
for /f "delims=" %%a in ('powershell -NoProfile -Command "Get-AppxPackage -AllUsers ^| Where-Object { $_.PackageFullName -like '*microsoftedge*' } ^| Select-Object -ExpandProperty PackageFullName"') do (
    if not "%%a"=="" (
        set "APP=%%a"
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\!USER_SID!\!APP!" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\EndOfLife\S-1-5-18\!APP!" /f >nul 2>&1
        reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Appx\AppxAllUserStore\Deprovisioned\!APP!" /f >nul 2>&1
        powershell -Command "Remove-AppxPackage -Package '!APP!'" 2>nul
        powershell -Command "Remove-AppxPackage -Package '!APP!' -AllUsers" 2>nul
    )
)
for /f %f in ('dir /s /b %SystemRoot%\SystemApps\Microsoft.MicrosoftEdge*') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
for /f %f in ('dir /s /b %SystemRoot%\System32\MicrosoftEdge*.exe') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
for /f %f in ('dir /s /b %SystemRoot%\SysWOW64\MicrosoftEdge*.exe') do (takeown /f "%f" && icacls "%f" /grant everyone:F && del /f /q "%f")
echo Microsoft Edge should be now uninstalled.
echo Please reboot Windows.
pause
goto eof

:noedge
echo Preinstalled Edge Chromium was not found!
pause

:eof
