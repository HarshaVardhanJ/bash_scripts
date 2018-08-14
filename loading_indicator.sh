#!/usr/bin/env bash
#
#: Title		:	loading_indicator.sh
#: Date			:	14-Aug-2018
#: Author		:	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version		:	1.0 (Stable)
#: Description	:	Displays characters declared in an array with a delay
#					to simulate loading.
#: Options		:	None


function loading() {
	# Array containing characters that show loading progression
	LOAD=("-" "\\" "|" "/")

	# If the number of arguments passed is one and equal to a number
	if [[ $# -eq 1 && $1 =~ ^[0-9]+([.][0-9][0-9]) ]]
	then
		WAIT="${1}"
	else
		WAIT="0.3"
	fi

	while true
	do
		for i in "${LOAD[@]}"
		do
			printf "\\b%s" "${i}"
			sleep "${WAIT}"
		done
	done
}

loading "${1}"
