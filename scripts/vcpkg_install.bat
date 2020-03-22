@echo off

rem git clone https://github.com/Microsoft/vcpkg.git
git clone https://github.com/hikanashi/vcpkg.git

cd vcpkg
powershell -Command ".\bootstrap-vcpkg.bat"
REM powershell -Command ".\vcpkg integrate install"
pause