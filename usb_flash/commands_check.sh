#!/usr/bin/env bash
#
#: Title        : commands_check.sh
#: Date         :	31-Jan-2019
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1 (Stable)
#: Description  : This module checks if all the commands passed to
#                 it as arguments exist. If any of the commands do
#                 not exist on the machine, they are returned as
#                 output. If no output is generated, then all the
#                 commands passed to the script exist on the machine.
#                 The commands that don't exist are printed to stdout.
#
#                 The script requires either commands or an array that
#                 contains the commands to be checked as input. If the
#                 commands are passed directly, they should be quoted and
#                 space-separated. The script outputs the commands which
#                 don't exist from the list of commands given as input.
#
#                 ./script_name "exists1" "exists2" "nonexistent"
#                 exists1 exists2
#                 nonexistent
#
#                 ./script_name "who" "date"
#                 who date
#
#                 ./script_name "who" "dat" "ping"
#                 who ping
#                 dat
#                
#: Options      : Commands whose existence is to be checked are to be
#                 passed to the script as arguments. Each command should
#                 be quoted. Multiple commands should be space-separated.
#: Usage        :	Call the script with arguments.
#                 ./commands_check "command-1" "command-2"
#                 ./commands_check "date" "whoami" "ping"
#                 ./commands_check CommandArray
#                     where CommandArray=("command-1" "command-2")
################

# Exit when a command fails and returns a non-zero exit code
set -e

# script_name CommandArray
#   where CommandArray=("whoami" "date" "time")
# or
# script_name "whoami" "date" "time"
#
# or
# script_name "whoami"
#
# Function that accepts :
#         1). An array containing list of commands to be checked
#         2). One/multiple commands, quoted and space-separated
# and checks to see if the commands exist on the local machine

function command_check__check_input() {
  # Array for storing commands whose
  # existence needs to be checked
  local -a CommandArray

  # Local array for storing the input array.
  local ArraySignature
  ArraySignature="declare -a"

  # If number of input arguments >= 1
  if [[ $# -ge 1 ]] ; then
    # If number of input arguments = 1
    if [[ $# -eq 1 ]] ; then
      # If the argument is not an empty string
      if [[ -n "$1" ]] ; then
        # If the argument is a valid shell variable
        if [[ -v $1 ]] ; then
          # If the input argument is an array
          if [[ $(declare -p $1 2>/dev/null) =~ "${ArraySignature}" ]] ; then
            CommandArray="${1[@]}"
          # If input argument is not an array
          else
            CommandArray+=("$1")
          fi
        # If input argument is not a shell variable
        else
          CommandArray+=("$1")
        fi
      # If the argument is an empty string
      else
        printf '%s\n' "Empty string given as argument" \
          && return 1
      fi

      # Print the array containing the commands
      printf '%s\n' "${CommandArray[@]}"
    # If number of arguments > 1
    else
      # For each argument given
      for ARGUMENT in "$@" ; do
        # If $ARGUMENT is not an array
        if [[ ! $(declare -p "${ARGUMENT}" 2>/dev/null) =~ "${ArraySignature}" ]] ; then
          # If $ARGUMENT is not an empty string
          if [[ -n "${ARGUMENT}" ]] ; then
            # Add it to the array containing a list of all commands
            CommandArray+=("${ARGUMENT}")
          # If $ARGUMENT is an empty string
          else
            printf '%s\n' "An empty argument has been passed." \
              && return 1
          fi

        # If $ARGUMENT is an array
        else
          prinf '%s\n' "The argument \"${ARGUMENT}\" is an array. If you wish \
            to pass an array, pass only the array as an argument." \
            && return 1
        fi
      done

      printf '%s\n' "${CommandArray[@]}"
    fi
  # If no arguments are given
  else
    printf '%s\n' "Insufficient number of arguments. Atleast one expected." \
      && return 1
  fi

}
# The output of the above function should be a list of commands that have been given \
# by the user. This output can be used by another submodule that can check if each of \
# the commands exist.


# This function checks the existence of commands on the local machine. It calls the \
# `command_check__check_input` function which checks the input to see if it contains \
# any empty strings if there are multiple arguments, or if the input argument is an array. \
# Once the input has been validated, the function will print all the commands to stdout, which \
# will be captured by the `command_check` function. This function then checks the commands' \
# existence and reports if any command does not exist.
# The commands that exist are printed first. The commands that do not exist are printed on the \
# next line.
function command_check() {

  # Local array to store names of commands that exist, and those \
  # that don't exist
  local -a NonexistentCommandArray
  local -a ExistentCommandArray
  
  # Local variable that stores the command which is used to \
  # check for the existence of other commands. On GNU/Linux \
  # and BSD systems, it is `which`
  local CommandCheckMethod
  CommandCheckMethod="which"

  # For a list of all commands returned by the `command_check__check_input` \
  # function, check if the commands exist
  for Variable in $(command_check__check_input "$@") ; do
    # If the command exists
    if [[ $("${CommandCheckMethod}" "${Variable}") ]] ; then
      ExistentCommandArray+=("${Variable}")
    # If the command does not exists
    else
      NonexistentCommandArray+=("${Variable}")
    fi
  done

  # If the array is non-zero in size, print it
  if [[ "${#ExistentCommandArray[@]}" -gt 0 ]] ; then
    printf '%s\t' "${ExistentCommandArray[@]}"
  else
    return 1
  fi

  # If the array is non-zero in size, print it
  if [[ "${#NonexistentCommandArray[@]}" -gt 0 ]] ; then
    printf '\n'
    printf '%s\t' "${NonexistentCommandArray[@]}" \
      && return 1
  fi

}

#command_check "$@"
# End of script