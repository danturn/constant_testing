if [ ! -d "shunit2" ]; then 
  git clone https://github.com/kward/shunit2.git 
fi

. constant_testing.sh test

assert_mix_path() {
  mix_path $1
  assertEquals $2 $mix_path
}

test_mix_path() {
  assert_mix_path project/test/the_test.exs project/
  assert_mix_path /dir/project/test/the_test.exs /dir/project/
  assert_mix_path /dir/test/project/test/the_test.exs /dir/test/project/
  assert_mix_path /dir/test/project/test/subdir/the_test.exs /dir/test/project/
  assert_mix_path /dir/lib/project/lib/subdir/the_test.exs /dir/lib/project/
}

. shunit2/source/2.1/src/shunit2
