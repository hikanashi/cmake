#!/bin/sh

packagelist="$@"

# clone vcpkg
if [ ! -d ./vcpkg ]; then
	# Microsoft vcpkg does not support authentication proxy.
	# Therefore, use a fork repository that supports the authentication proxy.
	# git clone https://github.com/Microsoft/vcpkg.git
	git clone https://github.com/hikanashi/vcpkg.git
fi

# update repo
cd vcpkg
git pull

# make vcpkg command
if [ ! -f ./vcpkg ]; then
	./bootstrap-vcpkg.sh
	# ./vcpkg integrate install
fi

# package install
# echo "Install Package... $packagelist"

# echo -n "Input proxy username:"
# read proxyuser

# echo -n "Input User($proxyuser)'s password:"
# read proxypass

# proxyschema=http://
# proxyauthority=127.0.0.1:8888

# export HTTP_PROXY=${proxyschema}${proxyuser}:${proxypass}@${proxyauthority}
# export HTTPS_PROXY=${proxyschema}${proxyuser}:${proxypass}@${proxyauthority}
# echo set HTTPS_PROXY=$HTTPS_PROXY

echo "vcpkg install $packagelist"
./vcpkg install $packagelist

