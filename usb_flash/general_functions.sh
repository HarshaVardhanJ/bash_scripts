#!/usr/bin/env bash
#
#: Title        : general_functions.sh
#: Date         : 07-Mar-2019
#: Author       : "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      : 0.1
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

# (WORKS)
#
# Function that helps print messages to standard error.
# The function accepts strings. Each string will be printed \
# on a new line. This function also provides the option of \
# returning any specific exit code. This value will need to be \
# passed as an argument to the '-e' flag
#
# Function input  : --exitcode 200 --string "Test string" --string "Test string2"
#                 : -e 200 -s "Test string" -s "Test string2"
#                 : -s "Test string"
# Function output : The string will be printed, and if an exit code is given, it will \
#                   be passed. If it is not given, only the string will be printed.
#
function print_err() {
	
	local returnCode
	local -a errorMessage

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
						printf '%s\n' "Expecting integer after the '-e' flag. Received \"$2\"." \
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
						printf '%s\n' "Empty string encountered." \
							&& return 1
					fi
				;;
				# If any other argument is provided
				*)
					printf '%s\n' "Incorrect argument(s). Check function's usage." \
						&& return 1
				;;
			esac
		done

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
			printf '%s\n' "${errorMessage["${VARIABLE}"]}" >&2
		done

		# If the 'returnCode' variable has been set
		if [[ -v returnCode ]] ; then
			# Return the value defined in the 'returnCode' variable
			return ${returnCode}
		fi

	# If number of arguments is not >= 2
	else
		print_err -e 1 -s "Incorrect number of arguments. Received $#. Requires an even number of arguments."
	fi

}


# Calling the 'print_err' function and passing all arguments to it
print_err "$@"