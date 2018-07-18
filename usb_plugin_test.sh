#!/bin/bash
#
# Script of a function that checks if any USB device has been inserted.
# Pass the number of seconds in between polling for USB device checks as
# an argument to the function, as shown in the script below.
# Numbers with up to two decimal places can be provided. '0.03' is a valid
# value but '0.001' is not.

function usb_check () {

	# If the number of arguments passed is one and equal to a number
	if [[ $# -eq 1 && $# =~ ^[0-9]+([.][0-9][0-9]) ]]
	then
		TIME=$1
	else
		TIME="0.1"
	fi

	while true
	do
		# If USB Device has been plugged in
		if [[ "$( system_profiler SPUSBDataType )" =~ "BSD Name" ]]
		then
			USB="$( system_profiler SPUSBDataType | grep "BSD Name" | cut -d":" -f2 | tr -d ' ' )"
			printf '%s' "${USB}" && return
		else
			sleep "${TIME}"
		fi
	done
}

usb_check $1
