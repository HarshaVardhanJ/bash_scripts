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
#: Usage		: Import/source this file at the beginning of each script 
#                 that requires any of the helper functions present in this 
#                 script.
################


# Function that checks if the number of arguments provided
# match a certain number. First argument must be the number
# of arguments that the user wishes to check. If you wish to
# check if 3 arguments have been passed, the first argument
# must be '3'. Then, the rest of the actual arguments follow.
# Function input  : 3 "$@"
# Function output : "$@" (arguments returned, if number matches)
function number_of_arguments() {

	# Variable that stores the number of arguments
	local argumentNumber

	# If the number of inputs is greater than or equal to 2
	# that is, the first must be a number and should be followed
	# by at least one other argument
	if [[ $# -ge 2 ]] ; then
		# If the first argument is a number between 1 and 10
		if [[  ]] ; then

		# If the first argument is not a number between 1 and 10
		else

		fi
	# If number of inputs is not >= 2
	else
		printf '%s\n' "$# argument(s) provided. Expected at least two." \
			&& return 1
	fi

}
