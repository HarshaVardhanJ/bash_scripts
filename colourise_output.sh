#!/usr/bin/env bash
#
#: Title        :	colourise_output.sh
#: Date         :	18-Aug-2018
#: Author       :	"Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :	1.0 (Stable)
#: Description  :	This script contains a function which
#                	helps colourise any string.
#: Options      :	Requires two arguments. First one is the colour, second is
#					the string to be printed.
#: Usage		:	The colour of the text is to be passed as the first argument.
#					The text to be printed is the second argument. Note that the
#					text should be passed in quotation marks. The colour can be
#                   case-insensitive too.
#					Example:	./colourise_output.sh blue "Text in blue"
#								./colourise_output.sh BlUe "Text in blue"
################

function colourise() {
	if tput setaf 1 &> /dev/null; then
		tput sgr0; # reset colors
		local -r BOLD=$(tput bold);
		local -r RESET=$(tput sgr0);
		# Solarized colors, taken from http://git.io/solarized-colors.
		local -r BLACK=$(tput setaf 0);
		local -r BLUE=$(tput setaf 33);
		local -r CYAN=$(tput setaf 37);
		local -r GREEN=$(tput setaf 64);
		local -r ORANGE=$(tput setaf 166);
		local -r PURPLE=$(tput setaf 125);
		local -r RED=$(tput setaf 124);
		local -r VIOLET=$(tput setaf 61);
		local -r WHITE=$(tput setaf 15);
		local -r YELLOW=$(tput setaf 136);
	else
		local -r BOLD='';
		local -r RESET=$'\e[0m'
		local -r BLUE=$'\e[1;34m'
		local -r CYAN=$'\e[1;36m'
		local -r GREEN=$'\e[1;32m'
		local -r ORANGE=$'\e[1;33m'
		local -r PURPLE=$'\e[1;35m'
		local -r RED=$'\e[1;31m'
		local -r VIOLET=$'\e[1;35m'
		local -r WHITE=$'\e[1;37m'
		local -r YELLOW=$'\e[1;33m'
	fi

	# Set case-insensitive matching in 'bash'
	# This is to help match the given colour in a case-insensitive fashion
	shopt -qs nocasematch

	if [[ $# -eq 2 && $1 =~ ^(blue|cyan|green|orange|purple|red|violet|white|yellow)$ ]]
	then
		local -r COLOUR="${1^^}"
		local -r STRING="${2}"

		printf '%s\n' "${!COLOUR}${STRING}${RESET}"
	else
		printf '%s\n' "Incorrect usage"
		printf '%-17s\t%s\n' "Usage : " "$0 colour \"Text to be coloured\""
		printf '%-17s\t%s\n' "Colours accepted:" "blue, cyan, green, orange, purple, red, violet, white, yellow"
	fi

	# Unset case-insensitive matching in 'bash'
	# Case-sensitive matching is the default behaviour in 'bash'
	shopt -qu nocasematch
}

colourise "$@"
