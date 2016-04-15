if [ -d "$1" ]; then
  echo "symlinking to $1"
  ln -f -s $(pwd)/constant_testing.sh $1/constant_testing.sh
else echo "$1 does not exist"
fi
