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
#                 2. This script can be used to obtain/print the
#                    aforementioned arrays. The variable array
#                    and file array can be obtained both
#                    individually and together.
#
#                 3. This script can be used to unset all shell
#                    variables stored in the array, and delete
#                    all files/folders listed in the array in the 
#                    form of variables.
#                
#: Options      : Accepts 'getvars', 'getfiles', 'delvars', 'delfiles',
#                 'getall', 'delall'
#
#                 'getvars'  --> Prints the variables stored by the
#                                function/script
#                 'getfiles' --> Prints the names and paths of files
#                                stored by the function/script
#                 'delvars'  --> Unsets all variables stored by the
#                                function/script
#                 'delfiles' --> Deletes all files/folders stored by
#                                the function/script
#                 'getall'   --> Prints the variables, files/folders
#                                stored by the function/script
#                 'delall'   --> Unsets all variables stored, and
#                                deletes all files/folders stored by
#                                the function/script
#                 
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
#                 
#                 Check the 'Options' above for a list and description
#                 of all arguments that the function accepts.
################


# ************************************** Script does not work.


# Importing the 'general_functions.sh' script
# Contains functions that will be used in this script
source ./general_functions.sh

# Function that checks if the input string is a 
# file/folder or a global variable
#
# Function input  : Accepts either a file/folder path, or a global variable
# Function output : A string decribing the type of input
#                   "File"           --> for file
#                   "Folder"         --> for folder
#                   "GlobalVariable" --> for global variable
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
    print_err -e 1 -s "Unknown"
  fi
}

# Function that prints the variable array and/or file array
# depending on the input to the function
# Function input  : FilesArray
#                   VarsArray
#                   Both the array names mentioned above can be
#                   changed if required. The variables are set
#                   during the 'Array Creation' stage of the 
#                   'var_file_collection_vars_files_array' function
# Function output : The appropriate array is expanded and printed
function var_file_collection__print_arrays() {

  # Local nameref variable
  # Meaning any variable expansion on 'ArrayName' will be \
  # performed on the variable it refers to.
  # For example, if 'testVar'=1, creating a nameref variable \
  # 'tempVar' and pointing it to 'testVar' will have the following \
  # effect when 'tempVar' is expanded.
  # testVar=1
  # declare -n tempVar=testVar
  # echo $tempVar
  # Output = 1
  # Check `man bash` for more information on namerefs
  local -n ArrayName

  # If number of arguments = 1, and the argument is not an empty string
  if [[ $# -eq 1 && -n "$1" ]] ; then
    # If the argument matches either the variable that the nameref 'VarsArrayName' \
    # or 'FilesArrayName' points to
    if [[ "$1" =~ "${!VarsArrayName}"|"${!FilesArrayName}" ]] ; then
      # Assigning the first argument to the 'ArrayName' nameref variable
      ArrayName="$1"
      # If the array exists, and has at least one element
      if [[ -v "${ArrayName}" && "${#ArrayName[@]}" -gt 0 ]] ; then
        # Print the elements of the array
        print '%s\n' "${!ArrayName[@]}"
      # If the array either does not exist, or is empty
      else
        print_err -e 1 -s "\"${!ArrayName}\" is either empty or not initialised."
      fi
    # If the argument does not match any of the allowed arguments
    else
      print_err -e 1 -s "Incorrect arguments. Expecting either \
        \"${!VarsArrayName}\" or \"${!FilesArrayName}\"."
    fi
  # If number of arguments is not equal to 1, or is an empty string
  else
    print_err -e 1 -s "Incorrect number of arguments, or the input string is empty."
  fi
}


# Function that deletes the variables in the variable array and/or 
# the files in the files array, depending on the input to the function
# Function input  : FilesArray
#                 : VarsArray
#                   Both the array names mentioned above can be
#                   changed if required. The variables are set
#                   during the 'Array Creation' stage of the 
#                   'var_file_collection_vars_files_array' function
# Function output : The appropriate array's elements are deleted. If it
#                   is a variable, it is unset. If it is a file/folder
#                   it is deleted.
function var_file_collection__delete_arrays() {

  # Local 'nameref' variable
  local -n ArrayName

  # If number of arguments = 1, and the argument is not an empty string
  if [[ $# -eq 1 && -n "$1" ]] ; then
    # If the argument is either the variable defined by the namerefs \
    # 'FilesArrayName' or 'VarsArrayName'
    if [[ "$1" =~ "${!VarsArrayName}"|"${!FilesArrayName}" ]] ; then
      # Assigning the argument to the nameref variable
      ArrayName="$1"

      # If the array exists and is non-empty
      if [[ -v "${ArrayName}" && "${#ArrayName[@]}" -gt 0 ]] ; then
        # If the variable that the first argument points to matches \
        # either the array defined by the nameref variable 'VarsArrayName' \
        # or 'FilesArrayName'.
        # Using indirection on a nameref returns the name of the variable that \
        # it refers to. Calling the nameref variable returns the value of the \
        # variable that it refers to.
        case "${!ArrayName}" in
          "${!VarsArrayName}")
            printf '%s\n' "Unsetting variables created by script."
            # For a list of elements listed in the array defined by the 'ArrayName' \
            # nameref variable
            for VARIABLE in "${ArrayName[@]}" ; do
              if [[ ! $(declare -p "${VARIABLE}") =~ "declare -n" ]] ; then
                # Unset the variable
                unset -v "${VARIABLE}" \
                  || print_err -e 1 -s "\"${VARIABLE}\" might be a read-only variable"
              # If VARIABLE is a 'nameref' variable
              elif [[ $(declare -a "${VARIABLE}") =~ "declare -n" ]] ; then
                # 'unset -v' will unset the variable that the nameref variable refers to, \
                # and 'unset -n' will unset the nameref variable itself. Therefore, both the \
                # nameref variable and the variable that it refers to will be unset.
                # Unset the variable that the nameref refers to, then unset the nameref \
                # variable itself.
                unset -v "${VARIABLE}" \
                  && unset -n "${VARIABLE}" \
                  || print_err -e 1 -s "Could not unset the nameref variable \"${VARIABLE}\"."
              fi
            done
            # Unset the variable that the nameref refers to, which is either \
            # 'VarsArray' or 'FilesArray'. There is no need to unset the nameref \
            # variable as it is a local variable whose scope is restricted to this \
            # function only.
            #
            # Unsetting the 'ArrayName' nameref without the prefix '$' unsets the variable \
            # that 'ArrayName' points to. If you try to unset '$ArrayName', you end up \
            # expanding the variable that 'ArrayName' points to.
            unset -v ArrayName \
              || print_err -e 1 -s "Could not unset the nameref variable \"${ArrayName}\"."
            # If the array is either empty, or does not exist
          ;;
          "${!FilesArrayName}")
            printf '%s\n' "Deleting files created by script."
            # For a list of variables in array defined by the nameref 'ArrayName'
            for VARIABLE in "${ArrayName[@]}" ; do
              # If the path defined by the value of the variable '$VARIABLE' is \
              # either a file or a directory, delete them
              if [[ -e "${!VARIABLE}" || -d "${!VARIABLE}" ]] ; then
                rm -ri "${!VARIABLE}" \
                  || print_err -e 1 -s "Could not delete \"${VARIABLE}\"."
              else
                print_err -e 1 -s "\"${!VARIABLE}\" - not a file/directory."
              fi
            done
            # Unset array associated with nameref variable
            unset -v ArrayName \
              || print_err -e 1 -s "Could not unset the variable \"${ArrayName}\"."
          ;;
        esac
      # If the array either does not exist, or is empty
      else
        print_err -e 1 -s "\"${!ArrayName}\" is empty or uninitialised."
      fi
    # If the argument does not match any of the arrays names defined by the namerefs \
    # 'VarsArrayName' and 'FilesArrayName'
    else
      print_err -e 1 -s "Argument mismatch. Received \"$1\". Expecting either \
        \"${VarsArrayName}\" or \"${FilesArrayName}\"."
    fi
  # If number of arguments is not equal to 1, or is an empty string
  else
    print_err -e 1 -s "Incorrect number of arguments or empty string received. \
      Expecting either 'FilesArray' or 'VarsArray'."
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
# Function input  : var_file_collection__vars_files_array PATH
# Function output : None. The variable 'PATH' is added to an array
#                   in order to keep track of it. If 'PATH' is not
#                   a valid shell variable, it is not added to the
#                   array.
#
# Function input  : var_file_collection__vars_files_array TestFile
#                   where TestFile="/path/to/file/"
# Function output : None. The variable 'TestFile' is added to an array
#                   in order to keep track of it. If "${TestFile}" is 
#                   not a valid file/folder that exists, it is not
#                   added to the array.
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
    ##########################################
    # Return/Delete global vars and/or files #
    ##########################################

    # If the argument matches any of the aforementioned defined arguments
    case "$1" in
      # If the argument received is the string contained in the variable $GetVarsArg
      "${GetVarsArg}")
        # Print the elements of the array containing the global variables \
        # set/created by the script
        # The variable 'VarsArrayName' is a nameref that points to the array that \
        # contains all the variables collected/stored by the script.
        #
        # Variable indirection, when used with a nameref, will point to the variable \
        # rather than the value of that variable. Look at example below
        #
        # declare -n VarsArrayName=VarsArray , where VarsArray is an array
        # ${VarsArrayName} --> Expands the VarsArray array
        # ${!VarsArrayName} --> prints 'VarsArray'
        #
        var_file_collection__print_arrays "${!VarsArrayName}"
      ;;
      # If the argument received is the string contained in the variable $GetFilesArg
      "${GetFilesArg}")
        # Print the elements of the array containing files/folders created \
        # by the script
        var_file_collection__print_arrays "${!FilesArrayName}"
      ;;
      # If the argument received is the string contained in the variable $GetAllArg
      "${GetAllArg}")
        # Print the elements of the array containing the global variables \
        # set/created by the script
        var_file_collection__print_arrays "${!VarsArrayName}"

        # Print the elements of the array containing files/folders created \
        # by the script
        var_file_collection__print_arrays "${!FilesArrayName}"
      ;;
      # If the argument received is the string contained in the variable $DelVarsArg
      "${DelVarsArg}")
        # Unset the variables which are elements of the array that the nameref \
        # 'VarsArrayName' points to
        var_file_collection__delete_arrays "${!VarsArrayName}"
      ;;
      # If the argument received is the string contained in the variable $DelFilesArg
      "${DelFilesArg}")
        # Delete the files and/or folders which are elements of the array that the \
        # nameref 'FilesArrayName' points to
        var_file_collection__delete_arrays "${!FilesArrayName}"
      ;;
      "${DelAllArg}")
        # Calling the 'var_file_collection__delete_arrays' function \
        # and passing 'VarsArray' as the argument. This unsets all \
        # variables listed in the array
        var_file_collection__delete_arrays "${!VarsArrayName}"

        # Calling the 'var_file_collection__delete_arrays' function \
        # and passing 'FilesArray' as the argument. This deletes all \
        # files and/or folders listed in the array
        var_file_collection__delete_arrays "${!FilesArrayName}"
      ;;
    esac
  fi

  ##################
  # Array Creation #
  ##################

  # If number of arguments >= 1, and if the first argument does not match any of the pre-defined \
  # arguments that are used to interact with the arrays
  if [[ $# -ge 1 && "$1" != "${GetVarsArg}"  && "$1" != "${GetFilesArg}"&& "$1" != "${DelVarsArg}" \
      && "$1" != "${DelFilesArg}" && "$1" != "${DelAllArg}" && "$1" != "${GetAllArg}" ]] ; then
    # Checking if the argument(s) is/are valid shell variables before adding \
    # them to the appropriate arrays.
    #
    # For each argument given
    for VARIABLE in "$@" ; do
      # If the argument is not a valid shell variable
      if [[ ! -v "${VARIABLE}" ]] ; then
        print_err -e 1 -s "\"${VARIABLE}\" is not a valid shell variable."
      fi
    done

    # Two arrays are required. One to store the names of global variables created \
    # by the script, and one to store the paths to files and/or folders created by \
    # the script.
    # Declaring two nameref variables that point to the arrays
    declare -gxn VarsArrayName="VarsArray"
    declare -gxn FilesArrayName="FilesArray"

    # Adding the above global nameref variables to the variable array
    #var_file_collection__vars_files_array "VarsArrayName" "FilesArrayName"

    # For a given list of arrays, if they don't exist, create them.
    # Using indirection on a nameref variable will return the name \
    # of the variable that it refers to. Using variable expansion will \
    # return the value of the variable it refers to.
    # Below, variable indirection is used, which will return the names \
    # of the variables it refers to
    for VARIABLE in "${!VarsArrayName}" "${!FilesArray}" ; do
      # If $VARIABLE is not set, that is, if the arrays defined by $VARIABLE don't exist \
      # create them.
      if [[ ! -v ${VARIABLE} ]] ; then
        # Create global exportable arrays defined by $VARIABLE
        declare -gxa ${VARIABLE}
      fi
    done

    # Checking the input argument type and adding it to the appropriate array.
    #
    # For list of given argument, check if each is either a
    # shell variable, file/folder
    for VARIABLE in "$@" ; do
      VarType="$( var_file_collection__check_type "${VARIABLE}" )"
      # The print statement given below is only for troubleshooting/debugging \
      # purposes. It has to be removed when the script has been checked to be free \
      # of errors/bugs, and its behaviour is predictable for any(most) inputs
      #printf '%s\n' "${VarType}"

      # Add the argument to the appropriate arrays
      case "${VarType}" in
        "GlobalVariable") VarsArray+=("${VARIABLE}") ;;
        "File"|"Folder") FilesArray+=("${VARIABLE}") ;;
        *) print_err -e -s "\"${VARIABLE}\" Unknown type" ;;
      esac
    done

    # The below print statements are only for debugging purposes. They should be removed
    # before using this script in combination with other scripts.
    printf '%s\t' "${VarsArrayName[@]}"
    printf '%s\t' "${#VarsArrayName[@]}"
  fi
}

# Calling the main function
var_file_collection__vars_files_array "$@"
# End of script