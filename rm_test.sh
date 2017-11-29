#!/bin/bash

HOME="$( ls -d ~ )"
touch "${HOME}"/Desktop/testfile

cd "${HOME}"/Desktop
IMG="$( ls -d ./testfile )"


COMP=$( mktemp img_burn_script.XXX ) #|| COMP=$( mktemp img_burn_script&& )

function finish
{
	for FILE in "${IMG}" "${COMP}"
	do
		if [ -e "${FILE}" ]
		then
			cd $( dirname "${FILE}" ) && rm -r "${FILE}"
		fi
	done
}

trap finish 0 1 2 3 5 15