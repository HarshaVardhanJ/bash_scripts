#!/bin/bash
#
#: Title		:	loading_indicator.sh
#: Date			:	14-Aug-2018
#: Author		:	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version		:	1.0 (Stable)
#: Description	:	Displays characters declared in an array with a delay
#					to simulate loading.
#: Options		:	None

# Array containing characters that show loading progression
LOAD=('-' '\' '|' '/')

while true
do
	for i in "${LOAD[@]}"
	do
		printf "\b%s" "${i}"
		sleep 0.3
	done
done
