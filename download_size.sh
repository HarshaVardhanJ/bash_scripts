#!/bin/bash
## Author		:	Harsha Vardhan J
## License		:	MIT
##
## Description	:	This script tries to output the download size when passed the URL of the file as an argument.
##					It uses 'wget' and 'curl' to find out what the file size is. It outputs values from 3 methods
##					used.


function download_size() {
	# If no argument is provided
	if [[ $# -ne 1 ]]
	then
		printf "$0 : URL not provided as argument. \n USAGE: $0 URL"
		exit 1
	elif [[ $# -eq 1  && $1 =~ http ]]
	then
		URL=$1
		wget --spider -r -l 10 "${URL}" 2>&1 | egrep "^Remote file exists" 1>/dev/null
		FILE_EXISTS=$?
	else
		printf "\n\t%s\n" "Either the argument is not a link or the download file doesn't exist."
		exit 1
	fi

	# Variable 'URL' assigned to first argument
	#URL=$1

	if [[ "${FILE_EXISTS:-1}" -ne 0 ]]
	then
		printf "\n%s\n" "Please check the download link provided. Could not determine if the download file exists."
	elif [[ "${FILE_EXISTS:-1}" -eq 0 ]]
	then
		printf "\n%s\n" "Remote file exists. Checking file size, please wait."
		RESPONSE1="$( wget --spider --server-response "${URL}" 2>&1 | awk '/^Length/{print $3}' | tr -d '()' )"
		RESPONSE2="$( wget --spider "${URL}" 2>&1 | awk '/^Length/{print $3}' | tr -d '()' )"
		RESPONSE3="$( curl --head "${URL}" 2>&1 | egrep "^Content-Length" | cut -d" " -f2 | awk '{$1=$1/1024^2; print $1,"MB";}' )"
		echo "The size of the file was obtained as : "
		printf "\tMethod-1 : ${RESPONSE1}\n"
		printf "\tMethod-2 : ${RESPONSE2}\n"
		printf "\tMethod-3 : ${RESPONSE3}\n"
	fi
}

download_size "$@"
