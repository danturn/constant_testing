#!/bin/bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then
  apt-get install fswatch -y
elif [[ "$OSTYPE" == "darwin"* ]]; then
  echo "MAC"        # Mac OSX
else
  echo "OMG, what os is this: $OSTYPE"
  exit -2;
fi

if [ -d "$1" ]; then
  echo "symlinking to $1"
  ln -f -s $(pwd)/constant_testing $1/constant_testing
else echo "$1 does not exist"
fi
