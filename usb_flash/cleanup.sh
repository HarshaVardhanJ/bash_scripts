#!/usr/bin/env bash
#
#: Title        : cleanup.sh
#: Date         : 13-Mar-2019
#: Author       : "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1
#: Description  : 
#                
#                
#                
#                
#: Options      :
#: Usage		:
################


# Importing the 'general_functions.sh' script
source ./general_functions.sh

# Local array that stores paths to files that need \
# to be imported
local -a IMPORT_FILES

# Files to be imported
IMPORT_FILES=("./var_file_collection.sh" \
				"./commands_check.sh")

# Calling the 'import_files' function and passing the \
# elements of the 'IMPORT_FILES' array as arguments
import_files "${IMPORT_FILES[@]}"


# Function that helps cleanup after the script has stopped \
# or finished running.
# Accepts two arguments : 'dryrun' - Displays all the files \
#                                    that will be deleted and \
#                                    the variables that will \
#                                    be unset.
#                         'clean'  - Deletes all files created \
#                                    by the script, and unsets \
#                                    all variables declared by \
#                                    the script.
#
function cleanup() {

	# Local variables that store the allowed arguments to be \
	# passed in
	local DryrunArg="dryrun"
	local CleanArg="clean"

	# If one argument is passed
	if [[ $# -eq 1 ]] ; then
		# If the argument is not an empty string
		if [[ -n "$1" ]] ; then
			case "$1" in
				# If the argument is "${DryrunArg}", obtain all the files and variables stored by the \
				# 'var_file_collection__vars_files_array' function, and print them out
				"${DryrunArg}") var_file_collection__vars_files_array "getvars" | tr '\n' ' ' | print_err - ;;
				# If the argument is "${CleanArg}", obtain all the files and variables stored by the \
				# 'var_file_collection__vars_files_array' function, and delete/unset them
				"${CleanArg}") var_file_collection_vars_files_array "delvars" ;;
				# If any other argument is received, print an error message
				*) print_err "Incorrect argument. Accepts only 'dryrun' and 'clean'." \
						&& return 1 ;;
			esac
		else

		fi

	else

	fi
}
