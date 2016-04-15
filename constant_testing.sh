#!/bin/bash

function run_all {
  log_info "$path$file changed... running all the tests from: `pwd`"
  mix_test
}

function mix_test {
  log_info "Running: mix test $1"
  output=`mix test $1` 
  result=$?
  echo "$output"
  if [[ $result != 0 ]]; then
    log_failure "OOOPPPPSIE - Somewhat predictably, you've broken something"
  else 
    log_success "Congratulations, you haven't broken anything... yet..."
  fi
}

function log_info {
  echo -e "\e[35m$1\e[39m"
}

function log_debug {
  if [[ $debug ]]; then
    echo -e "\e[33m$1\e[39m"
  fi
}

function log_failure {
  echo -e "\e[31m$1\e[39m"
}

function log_success {
  echo -e "\e[32m$1\e[39m"
}

function test_file_changed {
  log_debug "You changed the test file: $path$file so I'm running those tests for you"
  mix_test "test/$file" 
}

function file_changed {
  test_file="./test/${file%.*}_test.exs"
  if [ -f $test_file ]; then 
    log_debug "You changed the file: $path$file so I'll run the tests for that"
    mix_test "$test_file"
  else 
    log_failure "Uh-oh, You don't have tests for this do you?"
  fi
}
 
function install_tools {
  if [ $(dpkg-query -W -f='${Status}' inotify-tools 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get install inotify-tools
  fi
}

install_tools
log_info "I'm going to watch you work... in a creepy way"
if [[ $1 == "--debug" ]]; then debug=1; fi 

inotifywait -m -r -q --exclude '(.swp)' -e close_write ./ |  
  while read path action file; do 
    if [[ "$file" == *.exs || "$file" == *.ex ]]; then 
      cd $path../
      if [[ "$file" == *_test.exs ]]; then test_file_changed
      elif [[ "$file" == *.ex ]]; then file_changed; fi
      log_info "I'm watching you..."
      cd - > /dev/null
    fi
  done
