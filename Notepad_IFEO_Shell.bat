@echo off
setlocal enabledelayedexpansion
pushd %~dp0

set getadminfile="%temp%\getadmin.vbs"
set "mytitle=Notepad 2/3 IFEO ^& Shell"
set "mytitsp=------------------------"
set usage0=Usage:
set usage1=^ ^ Register: Drap a Notepad3.exe or Notepad2.exe file to this bat.
set usage2=^ ^ Unregister: Run this bat.

rem UAC code begin
set getadminfile="%temp%\getadmin.vbs"
echo %mytitle%
echo %mytitsp%
echo Starting
"%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\SYSTEM" >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    goto :Admin
) else (
    if %ERRORLEVEL% EQU 2 (
        goto :PathErr
    ) else (
        goto :UAC
    )
)

:PathErr
echo.
echo Please open "%~n0%~x0" by explorer.exe
echo.
echo Press any key to explore the folder...
pause>nul
start "" "%SYSTEMROOT%\system32\explorer.exe" /select,"%~f0"
goto :END

:UAC
echo Set sh = CreateObject^("Shell.Application"^) > %getadminfile%
echo sh.ShellExecute "%~f0", "%~f1", "", "runas", 1 >> %getadminfile%
ping 127.1 -n 1 >nul
"%SYSTEMROOT%\system32\cscript.exe" %getadminfile%
goto :END

:Admin
if exist %getadminfile% ( del %getadminfile% )
cls
rem UAC code end

echo %mytitle%
echo %mytitsp%
echo %usage0%
echo %usage1%
echo %usage2%
echo.

:START
if "%~1"=="" (goto :REG_DEL) else (goto :REG_ADD)
goto :END

:REG_ADD
set myexe=%~n1%~x1
if /i "%myexe%" == "notepad3.exe" goto :REG_ADD_S
if /i "%myexe%" == "notepad2.exe" goto :REG_ADD_S
echo ERROR: Please drap a Notepad3.exe or Notepad2.exe file to this bat.
goto :END_P

:REG_ADD_S
:: Uninstall new version of notepad.exe
rem Get-AppxPackage *notepad* | Remove-AppxPackage
:: Add image hijacking
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v "Debugger" /t REG_SZ /d "\"%~f1\" /z" /f >nul 2>nul
reg add "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" /v "UseFilter" /t REG_DWORD /d 0 /f >nul 2>nul
:: Shell
reg add "HKCR\*\shell\%myexe%" /ve /t REG_SZ /d "%~n1" /f >nul 2>nul
reg add "HKCR\*\shell\%myexe%" /v "Icon" /t REG_SZ /d "\"%~f1\",0" /f >nul 2>nul
reg add "HKCR\*\shell\%myexe%\command" /ve /t REG_SZ /d "\"%~f1\" \"%%1\"" /f >nul 2>nul
if %ERRORLEVEL%==0 (echo OK) else (echo Failed)
goto :END_P

:REG_DEL
call :REG_DEL_F "HKLM\Software\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "Delete notepad.exe IFEO? (Y/N):"
call :REG_DEL_F "HKCR\*\shell\Notepad2.exe" "Delete Notepad2 Shell? (Y/N):"
call :REG_DEL_F "HKCR\*\shell\Notepad3.exe" "Delete Notepad3 Shell? (Y/N):"
goto :END_P

:REG_DEL_F
reg query "%~1" >nul 2>nul
if %ERRORLEVEL%==0 (
    set a=
    set /p a=%2
    if /i "!a!"=="y" (
        reg delete "%~1" /f >nul 2>nul
        if %ERRORLEVEL%==0 (echo OK) else (echo Failed)
    )
)
goto :eof

:END_P
echo Press any key to exit...
pause >nul

:END
if exist %getadminfile% ( del %getadminfile% )
popd
