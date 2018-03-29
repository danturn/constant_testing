#!/bin/bash

mix_test() {
  log_info "Running: mix test $1"
  output=`mix test $1 --color` 
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
  if [[ $DEBUG ]]; then
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

any_file_changed() {
  test_path_without_line=${test_path%:*}
  if [ -f $test_path_without_line ]; then 
    log_debug "Running fixed tests: $test_path"
    mix_test "$test_path"
  else 
    log_failure "Uh-oh, that path you gave me doesnt exist ($test_path)"
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

clear_screen() {
  tput reset
}

watch() {
  install_tools
  clear_screen
  log_info "I'm going to watch you work... in a creepy way"

  inotifywait -m -r -q --exclude '(.swp)' -e close_write ./ |  
  while read path action file; do 
    if [[ "$file" == *.exs || "$file" == *.ex ]]; then 
      if [ $FIXED_FILE ]; then
        clear_screen
        any_file_changed
      else 
        mix_path "$path$file"
        cd $mix_path
        clear_screen
        if [[ "$file" == *_test.exs ]]; then test_file_changed
        elif [[ "$file" == *.ex ]]; then file_changed; fi
        log_info "I'm watching you..."
        cd - > /dev/null
      fi
    fi
  done
}

POSITIONAL=()
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    -d|--debug)
      DEBUG=true
      shift # past argument
      ;;
    *)    # any option
      FIXED_FILE=true
      test_path=("$1") 
      shift # past argument
      ;;
  esac
done

if [ "$1" != "test" ]; then
  watch
fi
