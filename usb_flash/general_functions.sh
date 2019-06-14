#!/usr/bin/env bash
#
#: Title        : general_functions.sh
#: Date         : 07-Mar-2019
#: Author       : "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 1.0 (Stable)
#: Description  : This script contains functions that are frequently
#                 used by the 'usb_flash' program/scripts. Import this
#                 in the other scripts in order to use the functions.
#                 This script does not do anything when executed, as it
#                 only contains helper functions.
#                
#: Options      : Arguments required depends on the function
#: Usage		    : Import/source this file at the beginning of each script 
#                 that requires any of the helper functions present in this 
#                 script.
################

# Exit when a command fails and returns a non-zero exit code
set -e


# (WORKS)
#
# Function that helps print messages to standard error.
# The function accepts strings. Each string will be printed \
# on a new line. This function also provides the option of \
# returning any specific exit code. This value will need to be \
# passed as an argument to the '-e' flag. The function can also \
# print the function name(which will have to be passed as an 
# argument) and the line number (which will also have to be passed \
# as an argument).
#
# Function input  : --exitcode 200 --string "Test string" --string "Test string2"
#                 : -e 200 -s "Test string" -s "Test string2"
#                 : -s "Test string"
#                 : -f "functionName" -l "lineNumber" -s "string"
#                 : -l "lineNumber" -s "string"
#                 : -f "functionName" -s "string"
# Function output : The string will be printed, and if an exit code is given, it will \
#                   be returned. If it is not given, only the string will be printed. \
#                   There is also the option to print the function name and line number \
#                   if they are passed as arguments. The shell variable FUNCNAME contains \
#                   the name of all functions being called. The shell variable LINENO \
#                   contains the line number of the current command being executed.
#
function print_err() {
	
	# Variable to store return code received as argument
	local returnCode

	# Array that stores strings to be printed to standard error
	local -a errorMessage

	# Variable that contains name of the function from which this module is being called
	local funcName

	# Variable that contains line number from which this module is being called
	local lineNum

	# If the number of arguments is even and is >= 2
	if [[ $(( $# % 2 )) -eq 0 && $# -ge 2 ]] ; then
		# While the number of arguments is greater than 0
		while [[ $# -gt 0 ]] ; do
			case "$1" in
				# If the first argument is either '--exitcode' or '-e'
				--exitcode|-e)
					# If the second argument matches any postive or negative integer
					if [[ "$2" =~ (^[+-][1-9])?[0-9]+ ]] ; then
						returnCode="$2"
						# Shifts the first two arguments away. '-e 1' have been shifted away
						shift 2
					# If the second argument is not an integer
					else
						# While the 'print_err' function can be called to print the error and return \
						# an exit code, calling the function within the function, in this case, will \
						# result in an infinite loop because of the while statement. The function can \
						# be called outside the parent 'if' statement
						colourise -e 1 -c blue -s "${FUNCNAME}" -c yellow -s "${LINENO}" \
							-c red -s "Expecting integer after the '-e' flag. Received \"$2\"." \
								&& return 1
					fi
				;;
				# If the "first" argument is either '--string' or '-s'
				--string|-s)
					# If the second argument is not an empty string
					if [[ -n "$2" ]] ; then
						# Add the second argument to the 'errorMessage' array
						errorMessage+=("$2")
						# Shift away two arguments. '-s "Example" have been shifted away'
						shift 2
					# If the second argument is an empty string
					else
						colourise -e 1 -c blue -s "${FUNCNAME}" -c yellow -s "${LINENO}" \
							-c red -s "Empty string encountered after '-s' flag." \
								&& return 1
					fi
				;;
				# If the "first" argument is either '--func' or '-f'
				--func|-f)
					# If the second argument is not an empty string
					if [[ -n "$2" ]] ; then
						# Assign the value of the second argument to the 'funcName' variable
						funcName="$2"
						# Shift away two arguments
						shift 2
					else
						colourise -e 1 -c blue -s "${FUNCNAME}" -c yellow -s "${LINENO}" \
							-c red -s "No function name given" \
								&& return 1
					fi
				;;
				# If the "first" argument is either '--line' or '-l'
				--line|-l)
					# If the second argument is an integer
						if [[ "$2" =~ (^[+][1-9])?[0-9]+ ]] ; then
							lineNum="$2"
						# Shift away two arguments
						shift 2
						else
							colourise -e 1 -c blue -s "${FUNCNAME}" -c yellow -s "${LINENO}" \
								-c red -s "Expecting integer after the '-l' flag. Received \"$2\"." \
									&& return 1
						fi
				;;
				# If any other argument is provided
				*)
					colourise -e 1 -c blue -s "${FUNCNAME}" -c yellow -s "${LINENO}" \
						-c red -s "Incorrect argument(s). Check function's usage." \
							&& return 1
				;;
			esac
		done

		# If funcName variable is set, print it in blue
		if [[ -v funcName && -n "${funcName}" ]] ; then
			# Print the value of the variable
			colourise -c blue -s "${funcName}" -e 1 -n 0
		fi

		# If lineNum variable is set, print it in yellow
		if [[ -v lineNum && -n "${lineNum}" ]] ; then
			# Print the value of the variable
			colourise -c yellow -s "${lineNum}" -e 1 -n 0
		fi

		# Print the text
		# Cycle through all indices of the 'errorMessage' array
		#
		# seq 0 1 3 = 0 1 2 3
		# ${#errorMessage[@]} = Number of elements in $errorMessage array(which is equal to half of the number \
		# of arguments) which is equal to total number of times a string should be printed.
		# For each string, there are two arguments provided.
		#
		# 1 is being subtracted from ${#errorMessage[@]} because arrays in bash are indexed from 0 onwards.
		# So, if the array has 5 elements, the value of VARIABLE needs to range from 0 to 4, hence the \
		# subtraction.
		for VARIABLE in $( seq 0 1 $(( ${#errorMessage[@]} - 1 )) ) ; do
			# Print the elements of the 'errorMessage' array to standard error
			colourise -c red -s "${errorMessage["${VARIABLE}"]}" >&2
		done

		# If the 'returnCode' variable has been set
		if [[ -v returnCode ]] ; then
			# Return the value defined in the 'returnCode' variable
			return ${returnCode}
		fi

	# If number of arguments is not >= 2
	else
		print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s "Incorrect number of arguments. Received $#. Requires an even number of arguments."
	fi

}


# (WORKS)
#
# Function that logs all arguments to the defined log file
# Function input  : init "/path/to/file"
#                 : "string to be logged"
# Function output : None. Returns an exit code depending on
#                   whether the operation was successful.
#
function log_to_file() {

	# Local variable that stores argument for initialising
	# the log file
	local initArg
	initArg="init"

	# Local variable to store name of parent directory of log file
	# Used for temporary purposes only
	local logDir


	# If the first argument matches the string defined in 'initArg'
	if [[ $# -eq 2 && "$1" = "${initArg}" ]] ; then
		# Obtain the parent directory of the log file and assign it \
		# to the 'logDir' variable
		logDir="$(dirname "${2}")"

		# If parent directory of log file exists and is writeable by the user \
		# that the script is running as
		if [[ -d "${logDir}" && -w "${logDir}" ]] ; then
			# If the log file to be initialised does not exist
			if [[ ! -f "${2}" ]] ; then
				# Create the log file and assign its full path to the 'logFile' variable
				touch "${2}" \
					&& declare -gx logFile \
					&& logFile="$(readlink -f "${2}")"

				# Sending the 'logFile' global variable to the 'vars_files_array' subfunction, which \
				# adds the variable to an array for purposes of keeping track of all global variables \
				# which can be unset during the cleanup step.
				var_file_collection__vars_files_array logFile

			# If log file to be initialised exists
			else
				# If the 'logFile' variable has not been set
				if [[ ! -v logFile ]] ; then
					# Assigning to the log file to the 'logFile' variable
					declare -gx logFile \
						&& logFile="$(readlink -f "${2}")"

					# Sending the 'logFile' global variable to the 'vars_files_array' subfunction, which \
					# adds the variable to an array for purposes of keeping track of all global variables \
					# which can be unset during the cleanup step.
					var_file_collection__vars_files_array logFile

				# If the 'logFile' variable has been set and is the same as the file passed
				elif [[ "${logFile}" = "${2}" ]] ; then
					print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
						"The file \"${2}\" has already been initialised as the log file."
				# If the 'logFile' variable does not match the file passed
				elif [[ "${logFile}" != "$2" ]] ; then
					print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
						"A log file \"${logFile}\" has been initialised previously."
				fi
			fi
		# If the parent directory either does not exist, or is not writeable by \
		# the user that the script is running as
		else
			print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
				"Either the directory \"${logDir}\" does not exist, or it isn't writeable by \"${USER}\"."
		fi
			
	# If the number of arguments = 1, and if the first argument is not an empty string, \
	# and if the 'logFile' file exists
	elif [[ $# -eq 1 && -n "$1" && -f "${logFile}" ]] ; then
		# Append the input string to the log file
		printf '%s\n' "$1" >> "${logFile}"
	# If two arguments are received, and if the second one is not an empty string \
	# and if the 'logFile' variable has not been set
	elif [[ ! -v logFile ]] ; then
		print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
			"A log file has not yet been initialised. It can be done by running \
\`${FUNCNAME} init \"/path/to/file\"\`, and the file will be created and initialised for logging."
	# If none of the previous 'if' conditions were fulfilled
	else
		# If the 'logFile' variable has not been set
		[[ ! -v logFile ]] && print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
			"Incorrect argument. Received \"$1\". Check function's usage"
	fi

}


# (WORKS)
#
# Function that gets rid of any duplicates in the arguments passed, if any.
# The duplicate arguments are removed and only the unique ones are printed \
# to the output.
#
# Function input  : Var3 Var1 Var2 Var2 Var3 Var1 Var3
# Function output : Var1 Var2 Var3 (could be in a different order)
#
function remove_duplicate_args() {

	# Local array to store input arguments
	local -n argArrayName="argArray"

	# If the number of arguments is > 1
	if [[ $# -gt 1 ]] ; then
		# For a list of given arguments
		for ARGUMENT in "$@" ; do
			# If the argument is not an empty string
			if [[ -n "${ARGUMENT}" ]] ; then
				# Adding the argument to the array
				argArrayName+=("${ARGUMENT}")
			# If the argument is an empty string
			else
				print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s "Empty string received." \
					&& continue 1
			fi
		done

		# If the number of elements in the argument array > 0
		if [[ "${#argArrayName[@]}" -gt 0 ]] ; then
			# Print all the elements of the array and sort the unique values \
			# using 'sort -u', and add them back to the array \
			# AND then print the array to standard output
			argArrayName=($(printf '%s\n' "${argArrayName[@]}" | sort -u)) \
				&& printf '%s ' "${argArrayName[@]}"
		fi
	# If the number of arguments = 1
	elif [[ $# -eq 1 ]] ; then
		printf '%s ' "${1}"
	# If no arguments have been received
	else
		print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s "No arguments received." \
			&& exit 1
	fi

}


# (WORKS)
#
# Function that generates an 'import status' variable. Setting this variable helps \
# serve as a check against importing the same file multiple times. This also prevents \
# recursive importing, which can happen when one script imports another script that \
# imports the first script. Normally, this will result in an infinite loop. Setting \
# a value for an 'import status' variable helps prevent this. The value of the variable \
# can be checked. If it is not a defined value, the file can be imported.
# The function takes one argument, which is the file that needs to be imported. The \
# output of the function is the import status variable pertaining to that file which \
# was given as input.
#
# Function input  : "/path/to/file/to/be/imported"
# Function output : "filename_importStatus"
#
# Example input   : "/home/test/script.sh"
# Example output  : "script_importStatus"
function generate_import_status_name() {

	# Variable that stores the name of the import status variable generated
	local importVarName

	# If the number of arguments = 1, and if that argument is not an empty string, \
	# and if the argument is a regular file that exists
	if [[ $# -eq 1 && -n "$1" && -f "$1" ]] ; then
		# Modifying the input string to the required type (see examples below)
		# if input="/path/to/file.sh", importVarName="file_importStatus"
		# if input="./file.sh", importVarName="file_importStatus"
		# if input="/path/to/file", importVarName="file_importStatus"
		#
		# "${Var##*/}" strips away the path to the file and returns only the \
		# file name(with the extension, if any). This is done with the help of \
		# substring removal(check bash hacker's wiki for more information)
		#
		# "${Var%.*}" strips away the file extension, if any
		# "${Var%.*}_importStatus" strips away the file extension, if any, and \
		# appends the string '_importStatus' to the end of the variable
		importVarName="${1##*/}" \
			&& importVarName="${importVarName%.*}_importStatus"
		
		# Print the import status variable
		printf '%s\n' "${importVarName}"
	# If either the number of arguments is not 1, or the argument is an empty string, or if the \
	# file defined by the argument does not exist
	else
		print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
			"Incorrect number of arguments, or empty string, or non-existent file" \
				&& exit 1
	fi

}


# (WORKS)
#
# Function that sets the value of the import status variable. This function calls the \
# 'generate_import_status_name' function which returns the name of the import status \
# variable corresponding to the script name. This variable is set by this function. \
# Therefore, this function should be called to set the import status variable value \
# to ensure that a script isn't being imported multiple times.
#
# Function input  : "/path/to/file/to/be/imported"
# Function output : The file is imported(if it has not already been).
function set_import_status() {

	# Local variable to store name of import status variable
	local tempImportVarName

	# Obtaining the import status variable name generated by the \
	# 'generate_import_status_name' function
	tempImportVarName="$( generate_import_status_name "$@" )"

	# Declaring the import status variable as an exportable, global variable \
	# and setting its value to 1 which indicates that it has been imported, AND \
	# adding the variable to the collection array which keeps track of all global \
	# variables
	declare -gix "${tempImportVarName}"=1
	#declare -gix "${tempImportVarName}"=1 \
	#	&& var_file_collection__vars_files_array tempImportVarName

}


# (WORKS)
#
# Function that helps import file(s) into the script
# The function calls the 'generate_import_status_name' and 'set_import_status' \
# functions.
# Function input  : "/path/to/file" "/path/to/file2" "../relative/path/to/file3"
#                 : "${ArrayContainingFiles[@]}"
# Function output : Error message and exit code returned when import is unsuccessful
function import_files() {

	# Variable to store name of 'importStatus' variables that are dynamically generated \
	# based on the file that is being imported. If the name of the file that is being \
	# imported is 'general_function.sh', the name of the variable that stores the import \
	# status will be 'general_functions_importStatus'.
	# The generation of the variable's name is done by the 'generate_import_status_name' \
	# function.
	local importStatusName

	# If number of arguments is > 0
	if [[ $# -gt 0 ]] ; then
		# For a list of all arguments
		for VARIABLE in "$@" ; do
			# If the argument is not an empty string, and if it exists and is non-zero in size, \
			# and if the file readable by the script
			if [[ -n "${VARIABLE}" && -s "${VARIABLE}" && -r "${VARIABLE}" ]] ; then

				# Generating the import status variable name by giving the file name as input
				importStatusName="$(generate_import_status_name "${VARIABLE}")"

				# If the 'importStatus' variable has not been set, and if the value of that variable \
				# is not equal to 1(which is value that it will be set to, if the file has been imported)
				#
				# "${importStatusName}" gives the name of the import status variable
				# "${!importStatusName}" gives the value of the import status variable (variable indirection)
				if [[ ! -v "${importStatusName}" && "${!importStatusName}" -ne 1 ]] ; then
					# Set the import status variable first(to prevent the file \
					# from being imported multiple times), and then import the file
					# This is done because if the file being imported has a command \
					# that imports the current file, it might go on in an infinite \
					# loop
					set_import_status "${VARIABLE}" \
						&& source "${VARIABLE}"
				fi
			# If the file either does not exist, is unreadable, is of size zero, or is an empty string
			else
				print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
					"Empty argument, or unreadable file, or empty file, or file does not exist" \
						&& exit 1
			fi
		done

		# Adding the 'importStatus' variable to the VarsArray
		#var_file_collection__vars_files_array "${importStatusName}"

	# If no arguments have been given
	else
		print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s \
			"Received no arguments. Requires at least one." \
				&& exit 1
	fi
}

# Main function that should be called
function general_functions__main() {
	# Local array containing paths of scripts which are to be imported
	local -a importFiles
	importFiles=(
		"/Users/harshavardhanj/GitRepos/bash_scripts/usb_flash/var_file_collection.sh"
		"/Users/harshavardhanj/GitRepos/bash_scripts/usb_flash/commands_check.sh"
		"/Users/harshavardhanj/GitRepos/bash_scripts/usb_flash/colourise_output.sh"
	)

	# Import the files defined in the 'importFiles' array
	import_files "${importFiles[@]}"
}


# Unset the execute bit on this file. It does not need to be executed \
# directly. The functions and commands in this script will be executed \
# when it is sourced/imported by another script. Since this script \
# contains a collection of helper functions, except for the 'main' \
# function, no other command needs to be executed in this script.

# Calling the main function
general_functions__main

# End of script