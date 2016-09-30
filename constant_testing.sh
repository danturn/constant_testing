#!/bin/bash

run_all() {
  log_info "$path$file changed... running all the tests from: `pwd`"
  mix_test
}

mix_test() {
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
  test_path=${file_path/#lib/test}
  test_path=${test_path/%.ex/_test.exs}
}

install_tools() {
  if [ $(dpkg-query -W -f='${Status}' inotify-tools 2>/dev/null | grep -c "ok installed") -eq 0 ];
  then
    sudo apt-get install inotify-tools -y
  fi
}

run_specified_test_only() {
  log_debug "You changed the file: $path$file so I'll run mix test $test_path"
  mix_test "$test_path"
}

watch() {
  first_arg_status $1
  run_only_specified_test=false
  if [ $first_arg_set == true ]; then
    run_only_specified_test=true
    specified_test_path=$1
    log_info "You cannot be trusted not to break $specified_test_path"
    log_info "so I'm going to watch you work and make sure you don't... in a micromanagerial way"
  else
    log_info "I'm going to watch you work... in a creepy way"
  fi
  install_tools
  [[ $1 == "--debug" ]] && debug=1

  inotifywait -m -r -q --exclude '(.swp)' -e close_write ./ |
    while read path action file; do
      if [[ "$file" == *.exs || "$file" == *.ex ]]; then
        mix_path "$path$file"
        cd $mix_path
        if [[ $run_only_specified_test == true ]]; then
          test_path=$specified_test_path;
          run_specified_test_only
        elif [[ "$file" == *_test.exs ]]; then test_file_changed
        elif [[ "$file" == *.ex ]]; then file_changed; fi
        log_info "I'm watching you..."
        cd - > /dev/null
      fi
    done
}

first_arg_status() {
  first_arg_set=""
  if [ -z ${1+x} ]; then first_arg_set=false; else first_arg_set=true; fi
}

first_arg_status $1
if [ "$1" == "test" ]; then :;
elif [[ $1 == *"test/"*".exs:"* ]]; then watch $1
elif [ $first_arg_set == false ]; then watch; fi
