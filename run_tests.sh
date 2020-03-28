#!/usr/bin/env sh

apk --no-cache --update add curl
curl --silent --fail http://application/hello.html | grep 'Hello World!'
