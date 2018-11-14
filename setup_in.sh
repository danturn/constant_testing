if [ -d "$1" ]; then
  echo "symlinking to $1"
  ln -f -s $(pwd)/constant_testing $1/constant_testing
else echo "$1 does not exist"
fi
