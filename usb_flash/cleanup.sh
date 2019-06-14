#!/usr/bin/env bash
#
#: Title        : cleanup.sh
#: Date         : 13-Mar-2019
#: Author       : "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1
#: Description  : This function is used for cleanup purposes after
#                 the main script has finished/stopped running.
#                 This function, when called, will
#
#                   Unset all global variables stored in a specific
#                   array(the array that the nameref'VarsArrayName'
#                   points to. Check the 'var_file_collection.sh'
#                   file.), and deletes all files stored in a specific
#                   array('FilesArrayName'). This way, all global
#                   variables set by the script, and all files
#                   and folders created by the script can be unset and/
#                   or deleted.
#                
#                
#: Options      : At least one required. Accepts the following arguments
#                 
#                 - 'dryrun'
#                     Prints all the variables that will be unset
#                     and all the files/folders that will be deleted.
#                      
#                 - 'clean'
#                     Unsets all variables stored in 'VarsArrayName'
#                     and deletes all files and folders stored in
#                     'FilesArrayName'. Use option with caution.
#
#: Usage        : Call the 'cleanup' function from within other scripts
#                 and pass the appropriate argument to it. Check above
#                 for list of acceptable arguments.
################


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
				"${DryrunArg}") var_file_collection__vars_files_array "getall" ;;
				# If the argument is "${CleanArg}", obtain all the files and variables stored by the \
				# 'var_file_collection__vars_files_array' function, and delete/unset them
				"${CleanArg}")
					var_file_collection_vars_files_array "delall"
					var_file_collection__vars_files_array "cleanup"
				;;
				# If any other argument is received, print an error message
				*) print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s "Incorrect argument. Accepts only \"${DryrunArg}\" and \"${CleanArg}\"." ;;
			esac
		# If the argument is an empty string
		else
			print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s "Empty string received. Accepts either \"${DryrunArg}\" or \"${CleanArg}\"."
		fi
	# If number of arguments is not equal to 1
	else
		print_err -f "${FUNCNAME}" -l "${LINENO}" -e 1 -s "Received $# argument(s). Requires at least 1. Accepts either \"${DryrunArg}\" or \"${CleanArg}\"."
	fi
}

# Main function
function cleanup__main() {
	# Declaring local array
	local -a importFiles
	importFiles=("./var_file_collection.sh" \
				"./commands_check.sh")

	# Importing the 'general_functions.sh' script
	source "/Users/harshavardhanj/GitRepos/bash_script/usb_flash/general_functions.sh"
	
	# Calling the 'import_files' function
	import_files "${importFiles[@]}"
}

# Calling the main function
cleanup__main

# This file isn't meant to be executed. It is preferable to unset the 'execute' bit on this file.
# To solve the issue of circular dependencies, it is better to unset the execute bit on all scripts \
# that do not absolutely need it. This way, when a certain file is  imported/sourced, the commands \
# in it aren't executed. Ideally, only the file/script that is responsible for handling user input \
# would have the execute bit set.

# End of script
