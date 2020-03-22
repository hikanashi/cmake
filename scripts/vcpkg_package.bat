@echo off

set PROXYUSER=%USERNAME%

set PROXYPASS=
set /P PROXYPASS="Input User(%PROXYUSER%)'s password: "

set PROXYSHEMA=http://
set PROXYAUTHORITY=127.0.0.1:8888

set HTTP_PROXY=%PROXYSHEMA%%PROXYUSER%:%PROXYPASS%@%PROXYAUTHORITY%
set HTTPS_PROXY=%PROXYSHEMA%%PROXYUSER%:%PROXYPASS%@%PROXYAUTHORITY%
rem echo set HTTPS_PROXY=%HTTPS_PROXY%

cd vcpkg
vcpkg install openssl nghttp2 curl jansson libevent protobuf grpc

pause