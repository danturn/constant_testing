#!/bin/bash

run_all() {
  log_info "$path$file changed... running all the tests from: `pwd`"
  mix_test
}

mix_test() {
  log_info "Running: mix test $1"
  output=`unbuffer mix test $1` 
  result=$?
  echo "$output"
  if [[ $result != 0 ]]; then
    log_failure "OOOPPPPSIE - Somewhat predictably, you've broken something"
  else 
    log_success "Congratulations, you haven't broken anything... yet..."
  fi
}

log_info() {
  echo -e "\e[35m$1\e[39m"
}

log_debug() {
  if [[ $debug ]]; then
    echo -e "\e[33m$1\e[39m"
  fi
}

log_failure() {
  echo -e "\e[31m$1\e[39m"
}

log_success() {
  echo -e "\e[32m$1\e[39m"
}

test_file_changed() {
  if [ "$mix_path" == "" ]; then 
    log_failure "Cannot find a mix project for: $path$file"
  else
    log_debug "You changed the test file: $path$file so I'm running those tests for you"
    mix_test "$test_path" 
  fi
}

file_changed() {
  if [ -f $test_path ]; then 
    log_debug "You changed the file: $path$file so I'll run the tests for that"
    mix_test "$test_path"
  else 
    log_failure "Uh-oh, You don't have tests for this do you?"
  fi
}

mix_path() {
  [[ $1 =~ (^.*/)((test|lib)/.*$) ]]
  mix_path=${BASH_REMATCH[1]}
  file_path=${BASH_REMATCH[2]}
  if [[ -n $test_one_file_path ]]; then
    echo "mix path is just for one test"
    test_path=$test_one_file_path
  else
    test_path=${file_path/#lib/test}
    test_path=${test_path/%.ex/_test.exs}
  fi
}

install_tools() {
  if [ $(dpkg-query -W -f='${Status}' inotify-tools 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get install inotify-tools -y
  fi
  if [ $(dpkg-query -W -f='${Status}' expect 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get install expect -y
  fi
}

watch() {
  install_tools
  log_info "I'm going to watch you work... in a creepy way"
  [[ $1 == "--debug" ]] && debug=1 

  inotifywait -m -r -q --exclude '(.swp)' -e close_write ./ |  
    while read path action file; do 
      if [[ "$file" == *.exs || "$file" == *.ex ]]; then 
        mix_path "$path$file" $test_one_file_path
        cd $mix_path
        if [[ "$file" == *_test.exs ]]; then test_file_changed
        elif [[ "$file" == *.ex ]]; then file_changed; fi
        log_info "I'm watching you..."
        cd - > /dev/null
      fi
    done
}

files_to_test() {
  [[ $1 =~ (test/)([^_]*)(_test.exs)(.*) ]]
  if [[ ${BASH_REMATCH[1]} == "test/" && ${BASH_REMATCH[3]} == "_test.exs" && -z ${BASH_REMATCH[4]} ]]; then
    if [[ ! -f $1 ]]; then
      log_info "The file '$1' does not exist.\nI can only run tests that exist you tool."
      exit
    fi
    test_one_file_path=$1
  elif [[ -z $1 ]]; then 
    true
  else
    log_info "I did not understand your arguement '$1'\n\nRun me either\n - with no arguement\n - one arguement in the form of 'test/[your_test_name]_test.exs' (to only run that test on any elixir file change)"
    exit
  fi
}

if [ "$1" != "test" ]; then
  files_to_test $1
  watch
fi
