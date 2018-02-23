if [ ! -d "shunit2" ]; then 
  git clone https://github.com/kward/shunit2.git 
fi

. constant_testing.sh test

assert_mix_path() {
  mix_path $1
  assertEquals $2 $mix_path
}

assert_test_path() {
  mix_path $1
  assertEquals $2 $test_path
}

test_mix_path() {
  assert_mix_path project/test/the_test.exs project/
  assert_mix_path /src/project/test/the_test.exs /src/project/
  assert_mix_path /src/test/project/test/the_test.exs /src/test/project/
  assert_mix_path /src/test/project/test/subdir/the_test.exs /src/test/project/

  assert_mix_path /src/lib/project/lib/subfolder/the_test.exs /src/lib/project/
}

test_test_path() {
  assert_test_path project/test/the_test.exs test/the_test.exs
  assert_test_path project/test/subfolder/the_test.exs test/subfolder/the_test.exs

  assert_test_path project/lib/module.ex test/module_test.exs
  assert_test_path project/lib/subfolder/module.ex test/subfolder/module_test.exs
  assert_test_path lib/project/lib/subfolder/lib.ex test/subfolder/lib_test.exs
}

. shunit2/shunit2
