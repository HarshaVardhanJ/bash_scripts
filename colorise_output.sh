#!/usr/bin/env bash
#
#: Title        :	colorise_output.sh
#: Date         :	18-Aug-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	1.0
#: Description  :	This script contains a function which
#                	helps colorise a string.
#: Options      :	
#: Usage		:	The colour of the text is to be passed as the first argument.
#					The text to be printed is the second argument. Note that the
#					text should be passed in quotation marks.
#					Example:	./colourise_output.sh blue "Text in blue"
################

function colorise() {
	bold='';
    reset=$'\e[0m'
    blue=$'\e[1;34m'
    cyan=$'\e[1;36m'
    green=$'\e[1;32m'
    orange=$'\e[1;33m'
    purple=$'\e[1;35m'
    red=$'\e[1;31m'
    violet=$'\e[1;35m'
    white=$'\e[1;37m'
    yellow=$'\e[1;33m'

	if [[ $# -eq 2 && $1 =~ ^([Bb]lue|[Cc]yan|[Gg]reen|[Oo]range|[Pp]urple|[Rr]ed|[Vv]iolet|[Ww]hite|[Yy]ellow)$ ]]
	then
		local COLOUR="${1}"
		local STRING="${2}"

		printf "%s\n" "${!COLOUR}${STRING}${end}"
	else
		printf "%s\n" "Incorrect usage"
		printf "%-17s\t%s\n" "Usage : " "$0 colour \"Text to be coloured\""
		printf "%-17s\t%s\n" "Colours accepted:" "blue, cyan, green, orange, purple, red, violet, white, yellow"
	fi
}

colorise "$@"
