#!/usr/bin/env bash
#
#: Title        : os_check.sh
#: Date         :	26-Jan-2019
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1 (Stable)
#: Description  : This module returns the type of OS on which
#                 it is called. The names it returns are 'Linux' 
#                 and 'Mac'. These are the values returned by the 
#                 function, for now. More can be added, if needed.
#                
#: Options      : None required.
#: Usage        :	Import the file and call the 'os_check' function.
#                 This script does not need to have execute permission
#                 as it will be imported by other functions.
################

# Exit when a command fails and returns a non-zero exit code
set -e

# Importing the 'general_functions.sh' script
source ./general_functions.sh

# This ensures that the an infinite loop of recursive importing does not happen.
# That happens when 'file1' sources 'file2', and when 'file2' also sources/imports \
# 'file1'. To prevent this, the 'import_files' function was written. It sets a unique \
# global variable to every script after importing it. The next time the script is asked \
# to be imported via the 'import_files' function, it first checks if that unique global \
# variable has been set, and if it has, it does not import that script.
import_files "/Users/harshavardhanj/GitRepos/bash_scripts/usb_flash/general_functions.sh"


# (WORKS)
#
# Function that returns the type of OS on
# which the script is run. The return values
# are 'Linux' and 'Mac'. More can be added
# if needed.
#
# Function input  : None. Just call the function
# Function output : Returns the type of OS
# Example         : os_check (Calling the function)
#                 : Mac (Or Linux, depending on the OS)
function os_check() {

  # Associative array for storing values related \
  # to OS types
  local -A OsArray_Uname OsArray_OsType

  # Adding OS key-value pairs
  # The key is the output from the command used
  # to check OS type(for example, 'uname -o')
  # The value is the customised name for use in
  # other scripts.
  # ["'uname -o' output"]="customised name"
  OsArray_Uname=(\
  ["Linux"]="Linux" \
  ["Darwin"]="Mac" \
  )

  # Adding OS key-value pairs
  # The key is the output from the OSTYPE variable \
  # used to check OS type.
  # The value is the customised name for use in
  # other scripts.
  # ["'OSTYPE' output"]="customised name"
  OsArray_OsType=(\
  ["gnu-linux"]="Linux" \
  ["darwin"]="Mac" \
  )

  # Variable that stores the result of the command used for \
  # obtaining info about OS
  # Can be changed if necessary
  local -a OsCheckCommand
  OsCheckCommand="$(uname -o)"

  # If the 'OSTYPE' shell variable has been set
  if [[ -v OSTYPE ]] ; then
    # for Key in 'OsArray' keys (key-value pairs in associative array)
    for Key in "${!OsArray_OsType[@]}" ; do
      # If the OSTYPE variable returns a value that matches any of the \
      # keys of the associative array 'OsArray_OsType'
      if [[ "${OSTYPE}" =~ ${Key} ]] ; then
        printf '%s\n' "${OsArray_OsType["${Key}"]}" \
          && break
      else
        print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
        "Operating system type not in list. Check 'os_check' function."
      fi
    done
  # If the 'OSTYPE' shell variable has not been set  
  else
    # for Key in 'OsArray' keys (key-value pairs in associative array)
    for Key in "${!OsArray_Uname[@]}" ; do
      # If the OS check command returns a value that matches any of the \
      # keys of the associative array 'OsArray'
      if [[ "${OsCheckCommand}" = "${Key}" ]] ; then
        # Print 'value' of the OsArray corresponding to the matching key \
        # and break out of the 'for' loop
        printf '%s\n' "${OsArray_Uname["${Key}"]}" \
          && break
      else
        print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
        "Operating system type not in list. Check 'os_check' function."
      fi
    done
  fi

}


# This file isn't meant to be executed. It is preferable to unset the 'execute' bit on this file.
# To solve the issue of circular dependencies, it is better to unset the execute bit on all scripts \
# that do not absolutely need it. This way, when a certain file is  imported/sourced, the commands \
# in it aren't executed. Ideally, only the file/script that is responsible for handling user input \
# would have the execute bit set.

# End of script