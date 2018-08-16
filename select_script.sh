#!/usr/bin/env bash

function selector() {
	PS3="Pick a number : "
	ARRAY=('1' '2' '3' '4')

	select OPTION in "${ARRAY[@]}"
	do
#		echo "\"${OPTION}\" picked"
		return
		break
	done
}

selector
