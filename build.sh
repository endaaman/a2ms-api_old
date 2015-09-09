#!/bin/bash

git pull origin master
npm install
npm stop > /dev/null
npm run prod
nginx -s reload
