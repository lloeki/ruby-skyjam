#!/bin/sh
mkdir -p tmp/py
protoc -I=defs defs/skyjam/*.proto defs/skyjam/**/*.proto --python_out=tmp/py
