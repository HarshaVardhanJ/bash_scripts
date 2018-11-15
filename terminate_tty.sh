#!/usr/bin/env bash
#
#: Title        :   terminate_tty.sh
#: Date         :   06-Nov-2018
#: Author       :   "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :   2.0 (Stable)
#: Description  :   The script lists all other tty sessions and asks
#                   the user to pick one of them. The tty that is
#                   picked is terminated. The user also has an option
#                   of terminating all ttys at once.
#
#: Options      :	None required. None accepted.
#: Usage		:	Run the script. For example,
#                      ./terminate_tty.sh
################



# Cleanup function that unsets all variables and arrays used in this script
function finish() {
	for VAR in TTY_ARRAY KILL_TTY
	do
		# Unsetting/destroying variable/array
		unset -v "${VAR}"
	done
}


# Trap the following signals and run the 'finish' function to cleanup
trap finish EXIT SIGHUP SIGINT SIGTERM


# Function that generates an array that contains username and tty values
# of other tty sessions
function tty_list() {
	# Get value of own tty
	local SELF_TTY
	SELF_TTY="$(tty | cut -d'/' -f3)"

	# Declaring a global array to store values of user and associated tty
	declare -ga TTY_ARRAY

	# Maps all values of 'username tty' to the 'TTY_ARRAY' array
	mapfile -t TTY_ARRAY<<<"$(last | grep -E "tty|pts" | grep -i "logged in" | grep -iv "${SELF_TTY}" | awk '{print $1, $2}')"

	# If the 'TTY_ARRAY' array is not empty
	if [[ "${#TTY_ARRAY[@]}" ]] && [[ "${TTY_ARRAY[0]}" != "" ]]
	then
		# If there are more than 1 pseudo-terminals, add an option to kill all of them
		if [[ "${#TTY_ARRAY[@]}" -gt 1 ]]
		then
			# Adding the final 'kill all tty' option to the array
			TTY_ARRAY+=('kill all tty')
		fi
	else
		# Exit script if no pseudo-terminals are found
		printf '%s\n' "No pseudo-terminals found. Exiting."
		exit 1
	fi
}


# Function that helps pick a tty to be terminated
function tty_selector() {
	# Calling the 'tty_list' function to populate the 'TTY' array
	tty_list

	# PS3 prompt. Will be displayed while the user is prompted to pick a tty to terminate
	local PS3="Pick a tty to terminate. To terminate all of them, pick the last option. Or type 'q' to exit. 
	[1-${#TTY_ARRAY[@]}] : "

	while true
	do
		# Prompt user to pick a tty
		# The option number picked is stored $REPLY
		# The content of the option picked is stored in $TTY_PICKED
		select TTY_PICKED in "${TTY_ARRAY[@]}"
		do
			# If the option picked is a valid number which lies in a range of the
			# size of array
			if [[ "${REPLY}" =~ [1-"${#TTY_ARRAY[@]}"] ]]
			then
				# If the option picked is the last option, which is 'kill all tty'
				if [[ "${REPLY}" -gt 1 ]] && [[ "${REPLY}" -eq "${#TTY_ARRAY[@]}" ]]
				then
					# Add all tty values to an array 'KILL_TTY'
					# To explain the logic below, the 'TTY_ARRAY' is being expanded
					# to all its elements, from the 0th element to the last-but-one
					# element. The index of the last-but-one element is generated by
					# subtracting 1 from the total number of elements in the array.
					# ${ARRAY[@]:index_of_starting_element:number_of_elements}
					# number_of_elements = Total number of elements - 1
					# number_of_elements = $((${#ARRAY[@]}-1))

					# Declare a global array 'KILL_TTY'
					declare -ga KILL_TTY

					# Loop through elements of array and append the tty values to 'KILL_TTY' array
					for INDEX in "${TTY_ARRAY[@]:0:$((${#TTY_ARRAY[@]}-1))}"
					do
						KILL_TTY+=("$(printf '%s' "${INDEX}" | awk '{print $2}')")
					done
				else
					# Assign selected tty to global variable 'KILL_TTY'
					declare -g KILL_TTY
					KILL_TTY="$(printf '%s' "${TTY_PICKED}" | awk '{print $2}')"
				fi

				break 2
			# If the user enters 'Q' or 'q', exit the script
			elif [[ "${REPLY}" =~ Q|q ]]
			then
				exit 1
			# If any other value of entered/picked, re-prompt the user
			else
				printf '%s\n' "Incorrect option. Pick an option between 1 and ${#TTY_ARRAY[@]}"
			fi
		done
	done
}


# Function that kills the picked tty
function tty_kill() {
	# Calling the 'tty_selector' function to obtain the tty to be terminated
	tty_selector

	# If the 'KILL_TTY' variable is not empty, proceed
	if [[ "${KILL_TTY}" != "" ]]
	then
		# Check if the 'KILL_TTY' variable is an array
		if [[ "$(declare -p KILL_TTY)" =~ "declare -a" ]]
		then
			# Loop through all elements of the array 'KILL_TTY'
			for SESSION in "${KILL_TTY[@]}"
			do
				# Killing all tty in 'KILL_TTY' array
				pkill -t "${SESSION}" && printf '\n%s' "TTY '${SESSION}' has been terminated."
			done
		else
			# Killing the tty picked by the user
			pkill -t "${KILL_TTY}" && printf '\n%s\n' "TTY '${KILL_TTY}' has been terminated."
		fi
	fi
}

# Calling the 'tty_kill' function
tty_kill


# End of script
