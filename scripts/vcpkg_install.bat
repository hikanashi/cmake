@echo off

git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg
powershell -Command ".\bootstrap-vcpkg.bat"
powershell -Command ".\vcpkg integrate install"
pause