#!/usr/bin/env bash
#
#: Title        :	usb_listing.sh
#: Date         :	15-Aug-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	1.0 (Stable)
#: Description  :	This script returns information about any USB
#                	storage devices connected to the machine. This
#					data is stored in an array.
#: Options      :	The 'drive_selector' function takes an optional
#					argument which when given, is assigned to the
#					'PS3' variable.
#: Usage		:	Calling the functions will output the list of
#					either all devices, or devices that are recognised
#					as 'Removable' by the machine. Calling the
#					'drive_selector' function will display a menu from
#					which the user can pick an option which is then
#					printed out.
################

# Function that provides list of USB devices attached to machine
function usb_devices_list() {
	system_profiler SPUSBDataType \
		| awk '
			/Capacity:/{c=$2$3}
	        /Removable Media:/{r=$3}
			/BSD Name:/{n=$3}
			/USB Interface:/{printf("%-10s\t%s\t%s\n", n, c, r)}
			'
}

# Function that filters the list of USB devices to those that are
# removable only
function usb_devices_filtered() {
	usb_devices_list \
		| awk -F '\t' '
			{ if ($3=="Yes"){printf("%s ", $1)} }
			'
}

# Print information about removable drives attached to the machine
function drive_info_print() {
	# Print header
	printf "%-10s\t%s\n" "Capacity" "Drive"
	# Print drive name and size
	usb_devices_list | awk '{printf("%10-s\t%s\n"), $1, $2}'
	printf "\n"
}

drive_info_print

# Function that prompts user to pick a drive
function drive_selector() {
	# If argument is given, assign it to 'PS3' variable.
	# Else, use 'PS3' variable defined in the loop.
	if [ $# -eq 1 ]
	then
		PS3=${1}
	else
		PS3="Pick a drive. Refer the above list before picking. Enter a number  :  "
	fi

	# Adding drive list to array
	ARRAY=($(usb_devices_filtered))

	# Select loop
	select OPTION in "${ARRAY[@]}"
	do
		printf "%s%s" "/dev/" "${OPTION}"
		break
	done
}

PICK=$(drive_selector "Pick a drive : ")
echo "${PICK}"
