#!/bin/bash
## Author		:	Harsha Vardhan J
## License		:	MIT
##
## Description	:	This script tries to output the download size when passed the URL of the file as an argument.
##					It uses 'wget' and 'curl' to find out what the file size is. It outputs values from 3 methods
##					used.

# If no argument is provided
if [ $# -ne 1 ]
then
	echo -e "$0 : URL not provided as argument. \n USAGE: $0 URL"
	exit 1
fi

# Variable 'URL' assigned to first argument
URL=$1

RESPONSE1="$( wget --spider --server-response "${URL}" 2>&1 | awk '/^Length/{print $3}' | tr -d '()' )"
RESPONSE2="$( wget --spider "${URL}" 2>&1 | awk '/^Length/{print $3}' | tr -d '()' )"
RESPONSE3="$( curl --head "${URL}" 2>&1 | egrep "^Content-Length" | cut -d" " -f2 | awk '{$1=$1/1024^2; print $1,"MB";}' )"

echo "The size of the file was obtained as : "
echo -e "\t Method-1 : ${RESPONSE1}"
echo -e "\t Method-2 : ${RESPONSE2}"
echo -e "\t Method-3 : ${RESPONSE3}"
