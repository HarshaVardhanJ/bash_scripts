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
#: Usage        :	Call the script.
#                 ./os_check
################

# Importing the 'general_functions.sh' script
source ./general_functions.sh

# Function that returns the type of OS on
# which the script is run. The return values
# are 'Linux' and 'Mac'. More can be added
# if needed.
#
function os_check() {

  # Associative array
  local -A OsArray

  # Local variable to store output of command
  # that returns info about OS
  local OsCheckMethod

  # Adding OS key-value pairs
  # The key is the output from the command used
  # to check OS type(for example, 'uname -o')
  # The value is the customised name for use in
  # other scripts.
  # ["'uname -o' output"]="customised name"
  OsArray=(\
  ["Linux"]="Linux" \
  ["Darwin"]="Mac" \
  )

  # Variable that stores the result of the command used for \
  # obtaining info about OS
  # Can be changed if necessary
  local OsCheckCommand
  OsCheckCommand="$(uname -o)"

  # for Key in 'OsArray' keys (key-value pairs in associative array)
  for Key in "${!OsArray[@]}" ; do
    # If the OS check command returns a value that matches any of the \
    # keys of the associative array 'OsArray'
    if [[ "${OsCheckCommand}" == "${Key}" ]] ; then
      # Print 'value' of the OsArray corresponding to the matching key \
      # and break out of the 'for' loop
      printf '%s\n' "${OsArray["${Key}"]}" \
        && break
    else
      printf '%s\n' "Operating system type not in list. Check 'os_check' function." \
        && return 1
    fi
  done

}

# Calling the main function
#os_check

# End of script