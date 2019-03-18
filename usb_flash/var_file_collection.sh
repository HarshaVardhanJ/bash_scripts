#!/usr/bin/env bash
#
#: Title        : var_file_collection.sh
#: Date         :	26-Jan-2019
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1
#: Description  : This module that has three uses
#                 1. Variables/files can be passed to it as
#                    arguments which will be stored in arrays.
#                    Files can be passed as variables only.
#                    If TestFile="/home/testfile", pass in
#                    TestFile as an argument to the script.
#
#                 2. This script can be used to obtain the
#                    aforementioned arrays
#
#                 3. This script can be used to unset all shell
#                    variables stored in the array, and delete
#                    all files listed in the array in the form
#                    form of variables
#                
#                
#: Options      : Accepts either 'getvars', 'delvars', or any
#                 shell variable.
#: Usage        :	Call the module/script and pass the argument.
#                 Examples
#
#                 The following adds PATH to the VarsArray array
#                 ./var_file_collection.sh PATH
#
#                 The following adds TestFile="/home/testfile" to the 
#                 FilesArray array
#                 ./var_file_collection.sh TestFile
#
#                 The following gets the array elements
#                 ./var_file_collection.sh getvars
#
#                 The following unsets all shell variables stored
#                 in the VarsArray, and deletes files/folders whose 
#                 paths are stored in FilesArray
#                 ./var_file_collection.sh delvars
################

# Importing the 'general_functions.sh' script
source ./general_functions.sh

# Function that checks if the input string is a 
# file/folder or a global variable
#
# Function input  : Accepts either a file/folder path, or a global variable
# Function output : A string decribing the type of input
function var_file_collection__check_type() {
  # Print the following as per the input type
  # If global variable, then 'GlobalVariable'
  # If file, then 'File'
  # If folder, then 'Folder'
  # If neither, then 'Unknown'
  # If first argument is either a shell variable, a file,
  # or a directory
  if [[ -v "$1" ]] ; then
    printf '%s\n' "GlobalVariable"
  elif [[ -a "${!1}" ]] ; then 
    printf '%s\n' "File"
  elif [[ -d "${!1}" ]] ; then
    printf '%s\n' "Folder"
  else
    print_err "Unknown" \
     return 1
  fi
}

# Function that prints the variable array and/or file array
# depending on the input to the function
# Function input  : FilesArray
#                 : VarsArray
# Function output : The appropriate array is expanded and printed
function var_file_collection__print_arrays() {

  # Local nameref variable
  # Meaning any variable expansion on 'ArrayName' will be \
  # performed on the variable it refers to.
  # Check `man bash` for more information
  local -n ArrayName

  # If number of arguments = 1, and the argument is not an empty string
  if [[ $# -eq 1 && -n "$1" ]] ; then
    ArrayName="$1"

    # If the argument is either 'FilesArray' or 'VarsArray'
    if [[ "${ArrayName}" =~ FilesArray|VarsArray ]] ; then
      # If the array exists, and has at least one element
      if [[ -v "${ArrayName}" && "${#ArrayName[@]}" -gt 0 ]] ; then
        print '%s\n' "${!ArrayName[@]}"
      # If the array either does not exist, or is empty
      else
        print_err "\"${!ArrayName}\" is either empty or not initialised." \
          && return 1
      fi
    # If the argument does not match any of the allowed arguments
    else
      print_err "Incorrect arguments. Expecting either 'FilesArray' or 'VarsArray'." \
        && return 1
    fi
  # If number of arguments is not equal to 1, or is an empty string
  else
    print_err "Incorrect number of arguments, or the input string is empty." \
      && return 1
  fi
}

# Function that does the following
#     1. Adds variables/files to VarsArray/FilesArray depending
#        on the type. Files also need to be passed as variables
#
#     2. Lists all variables stored in both arrays
#
#     3. Unsets all variables stored in VarsArray and
#        deletes all files stored as variables in FilesArray
#
function var_file_collection__vars_files_array() {
  # Local variables to store the arguments to be passed in

  # Argument that returns all variables stored/collected by this function
  local GetVarsArg
  GetVarsArg="getvars"

  # Argument that returns all files stored/collected by this function
  local GetFilesArg
  GetFilesArg="getfiles"

  # Argument that returns all variables and files stored/collected by \
  # this function
  local GetAllArg
  GetAllArg="getall"

  # Argument that deletes/unsets all variables stored/collected by this \
  # function
  local DelVarsArg
  DelVarsArg="delvars"

  # Argument that deletes all files stored/collected by this function
  local DelFilesArg
  DelFilesArg="delfiles"

  # Argument that unsets all variables and deletes all files stored/collected \
  # by this function
  local DelAllArg
  DelAllArg="delall"
  
  # Local variable to store the output value returned by
  # the check_type
  local VarType

  #######################################
  # Return/Delete global vars and files #
  #######################################

  # If number of input arguments = 1, and it is not a defined shell variable
  if [[ $# -eq 1 && ! -v "$1" ]] ; then
    #######################################
    # Return/Delete global vars and files #
    #######################################


    case "$1" in
      "${GetVarsArg}")
        # If VarsArray exists and is non-empty
        if [[ -v VarsArray && "${#VarsArray[@]}" -gt 0 ]] ; then
          printf '%s\n' "${VarsArray[@]}"
        else
          print_err "VarsArray is either empty or not initialised." \
            && return 1
        fi
      ;;
      "${GetFilesArg}")
        # If FilesArray exists and is non-empty
        if [[ -v FilesArray && "${#FilesArray[@]}" -gt 0 ]] ; then
          printf '%s\n' "${FilesArray[@]}"
        else
          print_err "FilesArray is either empty or not initialised." \
            && return 1
        fi
      ;;
      "${GetAllArg}") var_file_collection__print_arrays FilesArray ; \
                      var_file_collection__print_arrays FilesArray ;;
      "${DelVarsArg}") true ;;
      "${DelFilesArg}") true ;;
      "${DelAllArg}") true ;;


    esac

    # If argument received is $GetVarsArg, print the arrays
    if [[ "$1" == "${GetVarsArg}" ]] ; then
      # If VarsArray exists and is non-empty
      if [[ -v VarsArray && "${#VarsArray[@]}" -gt 0 ]] ; then
        printf '%s\n' "${VarsArray[@]}"
      else
        print_err "VarsArray is either empty or not initialised." \
          && return 1
      fi

      # If FilesArray exists and is non-empty
      if [[ -v FilesArray && "${#FilesArray[@]}" -gt 0 ]] ; then
        printf '%s\n' "${FilesArray[@]}"
      else
        print_err "FilesArray is either empty or not initialised." \
          && return 1
      fi
    # If argument received is not 'delvars'
    elif [[ "$1" != "${DelVarsArg}" ]] ; then
      print_err "Check argument given. Expecting either a shell variable, 'getvars', or 'delvars'." \
        && return 1
    fi

    ################################
    # Delete global vars and files #
    ################################

    # If argument received is $DelVarsArg, unset variables \
    # and delete files, both of which are listed in their \
    # respective arrays, VarsArray and FilesArray
    if [[ "$1" == "${DelVarsArg}" ]] ; then
      # If the variable VarsArray exists, and has more than 0 elements
      if [[ -v VarsArray && "${#VarsArray[@]}" -gt 0 ]] ; then
        printf '%s\n' "Unsetting variables created by script."
        # Unset all variables listed in VarsArray array
        for Variable in "${VarsArray[@]}" ; do
          unset -v "${Variable}" || return 1
        done
        unset -v VarsArray \
          || return 1
      else
        print_err "VarsArray is empty or not initialised" \
          && return 1
      fi

      # FilesArray=(File1 File2 Dir1)
        # where File1="/path/to/file1"
        # where File2="/path/to/file2"
        # where File3="/path/to/dir1"
      #
      # for Variable in "${FilesArray[@]}"
      #   where $Variable --> File1
      #   and ${!Variable} --> $File1 --> /path/to/file1

      # If the variable FilesArray exists, and has more than 0 elements
      if [[ -v FilesArray && "${#FilesArray[@]}" -gt 0 ]] ; then
        printf '%s\n' "Deleting files created by script."
        # For a list of variables in FilesArray
        for Variable in "${FilesArray[@]}" ; do
          # If the path defined by the value of the variable '$Variable' is \
          # either a file or a directory, delete them
          if [[ -e "${!Variable}" || -d "${!Variable}" ]] ; then
            rm -ri "${!Variable}" || return 1
          else
            print_err "\"${!Variable}\" - not a file/directory."
          fi
        done
        # Unset array associated with $FilesArray
        unset -v FilesArray || return 1
      else
        printf '%s\n' "FilesArray is empty or not initialised" \
          && return 1
      fi
    elif [[ "$1" != "${GetVarsArg}" ]] ; then
      print_err "Check argument given. Expecting either a shell variable, 'getvars', or 'delvars'." \
        && return 1
    fi
  fi

  ##################
  # Array Creation #
  ##################

  # If number of arguments >= 1
  if [[ $# -ge 1 && $1 != "${GetVarsArg}" && $1 != "${DelVarsArg}" ]] ; then
    # For each argument given
    for Variable in "$@" ; do
      # If the argument is not a valid shell variable
      if [[ ! -v "${Variable}" ]] ; then
        print_err "\"${Variable}\" is not a valid shell variable." \
          && return 1
      fi
    done

    # For a given list of arrays, if they don't exist, create them
    for Variable in VarsArray FilesArray ; do
      # If $Variable is not set, that is, if the arrays defined by $Variable don't exist \
      # create them.
      if [[ ! -v ${Variable} ]] ; then
        # Create global exportable arrays defined by $Variable
        declare -gxa ${Variable}
      fi
    done

    # For list of given argument, check if each is either a
    # shell variable, file/folder
    for Variable in "$@" ; do
      VarType="$( var_file_collection__check_type "${Variable}" )"
      # The print statement given below is only for troubleshooting/debugging \
      # purposes. It has to be removed when the script has been checked to be free \
      # of errors/bugs, and its behaviour is predictable for any(most) inputs
      #printf '%s\n' "${VarType}"

      # Add the argument to the appropriate arrays
      case "${VarType}" in
        "GlobalVariable") VarsArray+=("${Variable}") ;;
        "File"|"Folder") FilesArray+=("${Variable}");;
        # The below print statement will have to be removed. It will need to be \
        # replaced by a sensible exit code. Or the print statements could be sent \
        # to stderr, which is better for interactive uses and helps with logging.
        *) print_err '%s %s\n' "\"${Variable}\"" "Unknown type" && return 1 ;;
      esac
    done

    # The below print statements are only for debugging purposes. They should be removed
    # before using this script in combination with other scripts.
    #printf '%s\t' "${VarsArray[@]}"
    #printf '%s\t' "${#VarsArray[@]}"
  fi

}

# End of script