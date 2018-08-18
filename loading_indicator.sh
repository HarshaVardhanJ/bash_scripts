#!/usr/bin/env bash
#
#: Title		:	loading_indicator.sh
#: Date			:	14-Aug-2018
#: Author		:	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version		:	1.0 (Stable)
#: Description	:	Displays characters declared in an array with a delay
#					to simulate loading until the backgroud process's PID,
#					which is given as an argument to the function, terminates.
#: Options		:	Requires first argument as a PID(background process, preferably).


function loading() {
	LOAD=("-" "\\" "|" "/")	# Array containing characters that show loading progression
	WAIT="0.3"				# Refresh time between loading animation

	if [[ $# -eq 1 ]]	# If number of arguments is equal to one
	then
		if [[ $1 =~ ^[0-9]+ ]]	# If the first argument is an integer
		then
			PROC_ID="${1}"		# Assign the first argument to the local variable 'PROC_ID'.

			while [[ $(ps a | awk '{print $1}' | grep "${PROC_ID}") ]]	# While background process is running
			do
				local LOADING_FORMAT="  \\b\\b\\b\\b\\b\\b\\b[%s]  "	# Format for printing loading indicator
				
				for i in "${LOAD[@]}"		# Loop for printing loading indicator
				do
					printf "${LOADING_FORMAT}" "${i}"
					sleep "${WAIT}"
				done
			done
			printf "\\b\\b\\b\\b\\b\n"
		else
			printf "Process ID not given as argument"
		fi
	else
		printf "\n%s\n%s\n" "Too many or too few arguments provided" "This function takes the previous process's PID as an argument"
		printf "\t%s\n" "Usage: $0 \$!"
	fi
}

loading "${@}"
