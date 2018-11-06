#!/usr/bin/env bash
#
#: Title        :   terminate_tty.sh
#: Date         :   06-Nov-2018
#: Author       :   "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :   1.0 (Stable)
#: Description  :   The script lists all other tty sessions and asks
#                   the user to pick one of them. The tty that is
#                   picked is terminated.
#
#: Options      :	None required. None accepted.
#: Usage		:	Run the script. For example,
#                      ./terminate_tty.sh
################



# Function that generates an array that contains username and tty values
# of other tty sessions
function tty_list() {
	# Get value of own tty
	declare -r SELF_TTY="$(tty | cut -d'/' -f3)"

	# Initialise array and store user and tty data of other tty sessions
#	IFS=$'\n'
#	declare -rga TTY=( $(last | egrep "tty|pts" | grep -i "logged in" | grep -iv "${SELF_TTY}" | awk '{print $1, $2}') )
#	unset IFS

	# The above method is valid too. I've used the mapfile command instead.
	# Comment out the below three lines if you wish to use the above method.

	# Declaring a global array
	declare -ga TTY

	# Maps all values of 'username tty' to the 'TTY' array
	mapfile -t TTY <<<$(last | egrep "tty|pts" | grep -i "logged in" | grep -iv "${SELF_TTY}" | awk '{print $1, $2}')

	# Changing array type to read-only
	declare -r TTY
}


# Function that helps pick a tty to be terminated
function tty_selector() {
	# Calling the 'tty_list' function to populate the 'TTY' array
	tty_list

	# If 'TTY' array is not empty, proceed.
	if [[ "${#TTY[@]}" -gt 0 ]]
	then
		# Prompt user to pick a tty
		select OPTION in "${TTY[@]}"
		do
			# Assign selected tty to global, read-only variable 'KILL'
			declare -rg KILL="$(printf '%s' "${OPTION}" | awk '{print $2}')"
			break
		done
	fi
}


# Function that kills the picked tty
function tty_kill() {
	# Calling the 'tty_selector' function to obtain the tty to be terminated
	tty_selector

	# If the 'KILL' variable is not empty, proceed
	if [[ "${KILL}" != "" ]]
	then
		# Killing the tty picked by the user
		pkill -t "${KILL}" && printf '\n%s\n' "TTY '${KILL}' has been terminated."
	fi
}

# Calling the 'tty_kill' function
tty_kill


# End of script
