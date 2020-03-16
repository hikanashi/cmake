@echo off

if "%1" == "" goto PARAM_ERROR
if NOT EXIST "%1" (
 goto NOT_FOUND_ERROR
)

if "%2" == "" goto PARAM_ERROR
if NOT EXIST "%2" (
 goto NOT_FOUND_ERROR
)

explorer /e,/select,%2
explorer /e,/select,%1

exit /B

:PARAM_ERROR
echo パラメータエラー
exit /B

:NOT_FOUND_ERROR
echo ファイル、フォルダなしエラー
exit /B
