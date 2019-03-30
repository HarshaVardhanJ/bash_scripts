#!/usr/bin/env bash
#
#: Title        : var_file_collection.sh
#: Date         :	26-Jan-2019
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1 (Stable)
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


# Importing the 'general_functions.sh' script
# Contains functions that will be used in this script
source ./general_functions.sh


# (WORKS)
#
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
  if [[ -d "${!1}" ]] ; then
    printf '%s\n' "Folder"
  elif [[ -a "${!1}" ]] ; then 
    printf '%s\n' "File"
  elif [[ -v "${1}" ]] ; then
    printf '%s\n' "GlobalVariable"
  else
    print_err -e 1 -s "Unknown"
  fi
}


# (WORKS)
#
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

  # If number of arguments = 1, and the argument is not an empty string, and if the first \
  # argument matches either of the variables that the namerefs 'VarsArrayName' and \
  # 'FilesArrayName' point to
  if [[ $# -eq 1 && -n "$1" && "$1" =~ "${!VarsArrayName}"|"${!FilesArrayName}" ]] ; then
    # Assigning the first argument to the 'ArrayName' nameref variable
    ArrayName="$1"
    # If the array exists, and has at least one element
    if [[ -v "${ArrayName}" && "${#ArrayName[@]}" -gt 0 ]] ; then
      # Print the elements of the array
      printf '%s\n' "${ArrayName[@]}"
    # If the array either does not exist, or is empty
    else
      print_err -e 1 -s "\"${!ArrayName}\" is either empty or not initialised."
    fi
  # If number of arguments is not equal to 1, or is an empty string
  else
    print_err -e 1 -s "Incorrect number of arguments, or the input string is empty,\
      or the argument did not match either of the arrays' names."
  fi
}


# (WORKS)
#
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
  if [[ $# -eq 1 && -n "$1" && "$1" =~ "${!VarsArrayName}"|"${!FilesArrayName}" ]] ; then
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
            # If the variable does not match the signature of a nameref variable
            if [[ ! $(declare -p "${VARIABLE}") =~ "declare -n" ]] ; then
              # Unset the variable
              unset -v "${VARIABLE}" \
                || print_err -e 1 -s "\"${VARIABLE}\" might be a read-only variable"
            # If VARIABLE is a 'nameref' variable
            elif [[ $(declare -p "${VARIABLE}") =~ "declare -n" ]] ; then
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
          # variable 'ArrayName' as it's a local variable whose scope is restricted to this \
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
  # If number of arguments is not equal to 1, or is an empty string, or the input \
  # argument does not match any of the variable names that the namerefs 'VarsArrayName' \
  # and 'FilesArrayName' point to
  else
    print_err -e 1 -s "Incorrect number of arguments or empty string received. \
      Or the argument did not match either of the array's names."
  fi

}


# (WORKS)
#
# Function that creates the global arrays that are used to store \
# the variables, and files/folders that the script creates.
#
# This function is called by the 'add_to_array' module, and does not need \
# to be called directly. Calling the 'add_to_array' module will suffice as \
# it takes care of the array creation.
#
# Function input  : None required
# Function output : None. An error is returned if the arrays cannot be initialised
#
function var_file_collection__initialise_array() {

  ##################
  # Array Creation #
  ##################

  # If the variables defined by the namerefs 'VarsArrayName' or 'FilesArrayName' have \
  # not been declared
  # Note :  Previously, the check was done using the '-v' option. This did not work if \
  # the array did not have any elements and if it was only declared. The current condition \
  # works even when the array is empty.
  if [[ ! "$( declare -p "${!VarsArrayName}" 2>/dev/null )" =~ "declare -a" \
    || ! "$( declare -p "${!FilesArrayName}" 2>/dev/null )" =~ "declare -a" ]] ; then
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
    for VARIABLE in "${!VarsArrayName}" "${!FilesArrayName}" ; do
      # If $VARIABLE is not set, that is, if the arrays defined by $VARIABLE don't exist \
      # create them.
      if [[ ! -v ${VARIABLE} ]] ; then
        # Create global, exportable arrays defined by $VARIABLE
        declare -gxa ${VARIABLE} \
          || print_err -e 1 -s "Could not create variable \"${VARIABLE}\"."
      fi
    done
  fi

}


# (WORKS)
#
# Function that checks if the input argument(s) is/are present in the appropriate \
# array. If the arguments are not present in the array, they are returned as output. \
# If the arguments are present in the array, they are not returned. Also, if there are \
# any duplicate variables given as input, they too are not printed.
# For example, if the variable 'PATH' is already a part of the 'VarsArray' array, \
# providing 'PATH PWD' as input will result in an output of 'PWD'.
#
# This function can be used in the following ways : 
# 
# Call this function before adding any elements to the arrays. Pipe the output of this \
# function to the 'add_to_array' module. But in order for the function to be able to read \
# the piped input, a 'read' statement will need to be added to the first line of the \
# function that is ingesting the input. Therefore, it is better to call this function, and \
# add its output to a local variable which can then be expanded as input to the other function.
#
# Else, the 'add_to_array' module can call this function before the variables are added \
# to the arrays.
#
# Function input  : PATH PWD TempFile
# Function output : PATH PWD TempFile
#
# Function input  : PATH PWD PWD
# Function output : PATH PWD
function var_file_collection__present_in_array() {

  # Array to store the input arguments
  local -a inputVarArray

  # If the number of arguments is >= 1
  if [[ $# -ge 1 ]] ; then
    # For a list of all input arguments
    for VARIABLE in "$@" ; do
      # If the argument is not an empty string
      if [[ -n "${VARIABLE}" ]] ; then
        # For a list of all elements in the arrays that the namerefs 'VarsArrayName' and \
        # 'FilesArrayName' point to
        for ELEMENT in "${VarsArrayName[@]}" "${FilesArrayName[@]}"; do 
          # Check if element exists in the array
          # If the input argument matches any element of the array
          if [[ "${VARIABLE}" = "${ELEMENT}" ]] ; then
            # Continue to next iteration of main for-loop
            continue 2
          fi
        done

        # Add the argument to the 'inputVarArray'
        inputVarArray+=("${VARIABLE}")
      # If the argument is an empty string
      else 
        print_err -e 1 -s "Empty string received as argument."
      fi
    done
  # If less than 1 argument is provided
  else
    print_err -e 1 -s "Insufficient number of arguments. Expects at least one."
  fi

  # If the number of elements in the 'inputVarArray' array is > 0
  if [[ "${#inputVarArray[@]}" -gt 0 ]] ; then
    printf '%s ' "${inputVarArray[@]}"
  # If the array is empty
  else
    print_err -e 1 -s "No elements found in 'inputVarArray' array."
  fi
}


# (WORKS)
#
# Function that adds the input variable to the appropriate arrays.
# One array is used to keep track of global variables.
# The other array is used to keep track of variables that point to files and/or \
# folders created by the script.
#
# Function input  : Any variable that needs to be kept track of for purposes of \
#                   of cleanup post script completion.
# Function output : None. Returns an error if the input argument has not been \
#                   added to any of the arrays.
#
# Function input  : PATH  TestFile ; where TestFile="/path/to/file"
#                    |       |
#                    |       |
# Function output : None    None
function var_file_collection__add_to_array() {

  # Local variable to store the output value returned by
  # the check_type
  local VarType

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
  
  # If the arrays that the namerefs 'VarsArrayName' and 'FilesArrayName' point to \
  # have been declared
  if [[ "$( declare -p "${!VarsArrayName}" 2>/dev/null )" =~ "declare -a" \
    && "$( declare -p "${!FilesArrayName}" 2>/dev/null )" =~ "declare -a" ]] ; then
    # Checking the input argument type and adding it to the appropriate array.
    #
    # For list of given argument, check if each is either a
    # shell variable, file/folder
    for VARIABLE in "$@" ; do
      # Calling the 'check_type' module that checks the type of the input.
      # If it's a global variable, it returns 'GlobalVariable'
      # If it's a variable that points to a file/folder, it returns 'File' or 'Folder'
      # If it's neither, it returns an error
      VarType="$( var_file_collection__check_type "${VARIABLE}" )"

      # The print statement given below is only for troubleshooting/debugging \
      # purposes. It has to be removed when the script has been checked to be free \
      # of errors/bugs, and its behaviour is predictable for any(most) inputs
      printf '%s\n' "${VarType}"

      # Add the argument to the appropriate arrays
      case "${VarType}" in
        # If the argument is a global variable, add it to the array that the nameref \
        # 'VarsArrayName' points to
        #
        # Note : Normally, to refer to an array that a nameref points to, the nameref \
        # is expanded using ${!NAMEREF}, which prints the name of the array. BUT, to \
        # append values to the array, only the nameref needs to be used. That is, the \
        # '$' should not be present. So, to append values to an array, ARRAY, which the \
        # nameref 'NAMEREF' points to, we use
        # NAMEREF+=("VALUE")
        # Using "${!NAMEREF}"+=("VALUE"), although intuitive, will result in an error.
        # (This is one of those inconsistencies of bash that people keep talking about, \
        # I suppose.)
        "GlobalVariable") VarsArrayName+=("${VARIABLE}") ;;
        #"GlobalVariable") VarsArray+=("${VARIABLE}") ;;
        # If the argument is a variable that points to either a file/folder, add it to \
        # the array that the nameref 'FilesArrayName' points to
        "File"|"Folder") FilesArrayName+=("${VARIABLE}") ;;
        #"File"|"Folder") FilesArray+=("${VARIABLE}") ;;
        # If the argument is neither a global variable nor a variable pointing to a file \
        # or folder, print an error
        *) print_err -e 1 -s "\"${VARIABLE}\" Unknown type" ;;
      esac
    done

    # The below print statements are only for debugging purposes. They should be removed
    # before using this script in combination with other scripts.
    #printf '%s\t\t%s\n' "VarsArrayName : " "${VarsArrayName[@]}"
    #printf '%s\t\t%s\n' "FilesArrayName : " "${FilesArrayName[@]}"
    #printf '%s\t%s\n' "VarsArrayName Elements : " "${#VarsArrayName[@]}"
    #printf '%s\t%s\n' "FilesArrayName Elements : " "${#FilesArrayName[@]}"

  # If the arrays that the namerefs 'VarsArrayName' and 'FilesArrayName' point to don't exist
  else
    # Call the 'initialise_array' module AND then call the 'vars_files_array' module again and \
    # pass all the input arguments to it. The 'vars_files_array' module takes care of calling the \
    # 'present_in_array' module. It does not need to be called separately.
    var_file_collection__initialise_array \
      && var_file_collection__vars_files_array "$@"
  fi
}


# (WORKS)
#
# Function that does the following
#     1. Adds variables/files to VarsArray/FilesArray depending
#        on the type. Files also need to be passed as variables
#
#     2. Lists all variables stored in both arrays
#
#     3. Unsets all variables stored in VarsArray and
#        deletes all files stored as variables in FilesArray
#
# This function uses five other modules, namely
#                 1. array_creation
#                      This module creates the arrays that are
#                      used to store global variables and variables
#                      that point to files/folders. This module is
#                      called by the 'add_to_array' module.
#
#                 2. remove_duplicate_args
#                      This function removes any duplicates arguments
#                      from the input, if any, and prints out only the
#                      unique ones. This function is present in the
#                      'general_functions.sh'.
#
#                 2. present_in_array
#                      This module checks if the input arguments are
#                      present in any of the pre-defined arrays. If
#                      they are not, the argument is printed out.
#                      Supposing that 3 arguments are given, two of
#                      which are already present in both the arrays.
#                      In this case, the argument that isn't present
#                      in either of the arrays is printed. This is
#                      basically for checking if a variable has been
#                      added to either of the arrays previously.
#
#                 3. add_to_array
#                      This module adds the input argument, provided
#                      it is either a global variables, or a variable
#                      that points to a file/folder, to the appropriate
#                      array.
#
#                 4. print_arrays
#                      Prints the arrays, if they are populated.
#
#                 5. delete_arrays
#                      Unsets all variables in the array that stores
#                      variables, and deletes all files and folders
#                      that the script has created. Used for cleanup
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
#
function var_file_collection__vars_files_array() {

  # The above local variables have been replaced by the associative array.
  # Associative array containing arguments that help query the variable and file \
  # array
  local -A ArgArray
  ArgArray=( [GetVarsArg]="getvars" \
             [GetFilesArg]="getfiles" \
             [GetAllArg]="getall" \
             [DelVarsArg]="delvars" \
             [DelFilesArg]="delfiles" \
             [DelAllArg]="delall" )

  # Local variable that is used to check if the input argument matched any of the \
  # arguments listed above
  local -i FlagVar

  # Local array for storing arguments, temporarily
  local -a tempArray

  # For all values in the associative array (getvars, getfiles, ...delall)
  for VARIABLE in "${ArgArray[@]}" ; do
    # If the input argument matches any of the above allowed arguments
    if [[ "$1" = "${VARIABLE}" ]] ; then
      # Set the 'FlagVar' variable
      FlagVar=1
    fi
  done

  # Now, if the argument matched any of the pre-defined arguments above(getvars, \
  # getfiles, getall, delvars, delfiles, delall), the 'FlagVar' variable will be \
  # set. When the 'FlagVar' variable is set, the code can proceed to check which \
  # of the pre-defined arguments matches the input argument.
  

  #######################################
  # Return/Delete global vars and files #
  #######################################

  # If number of input arguments = 1, and if the 'FlagVar' variable is set(meaning if any \
  # of the above allowed arguments is passed)
  if [[ $# -eq 1 && -v FlagVar ]] ; then

    # If the argument matches any of the aforementioned defined arguments
    case "$1" in
      # If the argument received is the string contained in the variable $GetVarsArg
      "${ArgArray[GetVarsArg]}")
        # Print the elements of the array containing the global variables \
        # set/created by the script
        # The variable 'VarsArrayName' is a nameref that points to the array that \
        # contains all the variables collected/stored by the script.
        #
        # Variable indirection, when used with a nameref, will point to the variable \
        # rather than the value of that variable. Look at example below
        #
        # declare -n VarsArrayName=VarsArray , where VarsArray is an array
        # ${VarsArrayName} --> Expands the 'VarsArray' array
        # ${!VarsArrayName} --> prints 'VarsArray'
        #
        var_file_collection__print_arrays "${!VarsArrayName}"
      ;;
      # If the argument received is the string contained in the variable $GetFilesArg
      "${ArgArray[GetFilesArg]}")
        # Print the elements of the array containing files/folders created \
        # by the script
        var_file_collection__print_arrays "${!FilesArrayName}"
      ;;
      # If the argument received is the string contained in the variable $GetAllArg
      "${ArgArray[GetAllArg]}")
        # Print the elements of the array containing the global variables \
        # set/created by the script
        var_file_collection__print_arrays "${!VarsArrayName}"

        # Print the elements of the array containing files/folders created \
        # by the script
        var_file_collection__print_arrays "${!FilesArrayName}"
      ;;
      # If the argument received is the string contained in the variable $DelVarsArg
      "${ArgArray[DelVarsArg]}")
        # Unset the variables which are elements of the array that the nameref \
        # 'VarsArrayName' points to
        var_file_collection__delete_arrays "${!VarsArrayName}"
      ;;
      # If the argument received is the string contained in the variable $DelFilesArg
      "${ArgArray[DelFilesArg]}")
        # Delete the files and/or folders which are elements of the array that the \
        # nameref 'FilesArrayName' points to
        var_file_collection__delete_arrays "${!FilesArrayName}"
      ;;
      "${ArgArray[DelAllArg]}")
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

  ##################
  # Array Creation #
  #      and       #
  # Add Vars/Files #
  ##################

  # If the number of arguments >= 1, and if the 'FlagVar' variable has not been set
  elif [[ $# -ge 1 && ! -v FlagVar ]] ; then
    # Calling the 'remove_duplicate_args' function and passing input arguments to it. \
    # A list of all unique arguments are returned, which are saved in 'tempArray'.
    #
    # Calling the 'present_in_array' module and passing elements of 'tempArray' to it. \
    # The output of this module(except the errors) is added to an array(tempArray).
    tempArray=($(remove_duplicate_args "$@" 2>/dev/null))
    tempArray=($(var_file_collection__present_in_array "${tempArray[@]}" 2>/dev/null))

    # The above command that adds the unique variables to a temporary array could be \
    # replaced by the mapfile command, as per the recommendation from 'shellcheck'

    # If the temporary array has more than 0 elements
    if [[ "${#tempArray[@]}" -gt 0 ]] ; then
      # Providing the elements of the 'tempArray' array as input to the 'add_to_array' module
      # This array obtains
      var_file_collection__add_to_array "${tempArray[@]}"
    # If the 'tempArray' array is empty
    else
      print_err -e 1 -s "No output from the 'present_in_array' module. Input already exists in array."
    fi
  

  # If the input argument(s) does not match any of the previous conditions
  else
    print_err -e 1 -s "Argument(s) received : \"$*\". Does not match any of the conditions."
  fi
}

# Calling the main function and passing all input arguments to it
#var_file_collection__vars_files_array "$@"

# End of script