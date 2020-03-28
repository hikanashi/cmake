@echo off

:loop
	if "%~1" == "" goto end
	set PACKAGELIST=%PACKAGELIST% %~1
	shift
	goto loop
:end

rem clone vcpkg
if not exist vcpkg (
	REM git clone https://github.com/Microsoft/vcpkg.git
	git clone https://github.com/hikanashi/vcpkg.git
)

rem update repo
cd vcpkg
git pull

rem make vcpkg command
if not exist vcpkg.exe (
	powershell -Command ".\bootstrap-vcpkg.bat"
	REM powershell -Command ".\vcpkg integrate install"
)


set PKGTMP=pakage.tmp
set PACKAGETMP=
setlocal EnableDelayedExpansion

if exist %PKGTMP% (
	for /f "delims=" %%a in (%PKGTMP%) do (
		set PACKAGETMP=!PACKAGETMP! %%a
	)
)

if " %PACKAGELIST% " == "%PACKAGETMP%" (
	echo No need to build because the package is already installed
	exit /B
)
endlocal

rem package install

echo Install Package...

set PROXYUSER=%USERNAME%

set PROXYPASS=
set /P PROXYPASS="Input User(%PROXYUSER%)'s password: "

set PROXYSHEMA=http://
set PROXYAUTHORITY=127.0.0.1:8888

set HTTP_PROXY=%PROXYSHEMA%%PROXYUSER%:%PROXYPASS%@%PROXYAUTHORITY%
set HTTPS_PROXY=%PROXYSHEMA%%PROXYUSER%:%PROXYPASS%@%PROXYAUTHORITY%
rem echo set HTTPS_PROXY=%HTTPS_PROXY%

echo vcpkg install %PACKAGELIST%
vcpkg install %PACKAGELIST%

if %ERRORLEVEL% equ 0 (
    echo %PACKAGELIST% > %PKGTMP%
)
