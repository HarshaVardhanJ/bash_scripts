#!/bin/bash

## Author       :   Harsha Vardhan J
## License      :   MIT
##
## Description  :  This script downloads the link given below and check to see
##                 how many pulls have been made against that image returned by the search in that
##                 link.

# Function to delete created temporary file(s)
function finish
{
    for FILE in ${TEMP_FILE}
    do
        if [ -e "${TEMP_FILE}" ]
        then
            cd "$( dirname "${TEMP_FILE}" )" && rm -f "$( basename "${FILE}" )"
        fi
    done
}

# Trapping script exit(0), SIGHUP(1), SIGINT(2), SIGQUIT(3), SIGTRAP(5), SIGTERM(15) signals to cleanup temporary files
#trap finish 0 1 2 3 5 15
trap finish EXIT SIGHUP SIGINT SIGQUIT SIGTRAP SIGTERM

# Creating temporary file to store downloaded webpage
TEMP_FILE=$( mktemp -p "${TMPDIR}" wget.XXX )

# Link to webpage that is to be downloaded
LINK="https://hub.docker.com/search/?isAutomated=0&isOfficial=0&page=1&pullCount=0&q=harshavardhanj&starCount=0"

# Downloading webpage and storing in temporary file
wget "${LINK}" -O "${TEMP_FILE}" 2>/dev/null

# Filtering required information i.e. "pull_count" from the downloaded webpage
#PULLS="$(cat "${TEMP_FILE}" | awk '/\,\"pull_count\":[0-9]*.\,/' | awk -F',"pull_count":' '{print $2}' | awk -F',' '{print $1}')"
PULLS="$( awk '/\,\"pull_count\":[0-9]*.\,/' < "${TEMP_FILE}" | awk -F',"pull_count":' '{print $2}' | awk -F',' '{print $1}')"

# Displaying number of pulls
printf "\nNumber of pulls = "${PULLS}"\n"

######################################### End of script ###########################################
