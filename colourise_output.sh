#!/usr/bin/env bash
#
#: Title        :   colourise_output.sh
#: Date         :   18-Aug-2018
#: Author       :   "Harsha Vardhan J" <vardhanharshaj@gmail.com>
#: Version      :   2.0 (Stable)
#: Description  :   This script contains a function which
#                	helps colourise any string(s).
#: Options      :   Requires four arguments,at least. First one is the '--colour' option,
#                   second is the colour name, third is the '--string' option, fourth is 
#                   the string to be printed.
#: Usage        :   The colour of the text is to be passed as an argument
#                   to the '--colour' option. '--color' and '-c' are acceptable too. The 
#                   text to be printed is passed as an argument to the '--string' option.
#                   '-s' is acceptable too.
#                   Note that the text should be passed witin quotation marks. The colour 
#                   option can be case-insensitive too. Multiple strings with different 
#                   colours can be passed too.
#                   Example:    ./colourise_output.sh --colour blue --string "Text in blue"
#                               ./colourise_output.sh --color BlUe --string "Text in blue"
#                               ./colourise_output.sh --colour red --string "Red text" \
#                                                     -c blue -s "Blue text"
################

# Function that prints some text intended to inform the user
# about the script's usage
function print_help() {
	cat <<- EOF
Incorrect usage

Usage            :          $0 --colour colour --string "Text to be coloured"
                            $0 --color color --string "Text to be coloured"
                            $0 --color color --string "Text to be coloured" -c color -s "Text to be coloured"

Colours Accepted :          blue, cyan, green, orange, purple, red, violet, white, yellow

Note             :          All strings will be printed followed by a space. You do not need to add spaces between multiple strings
                            The strings should not be empty.

							The script accepts '--colour', '--color', and '-c' as flags for the colour(s)
							The script accepts '--string' and '-s' as flags for the string(s)

EOF
}

# Function containing all colour definitions(codes) and which prints the coloured text
function colourise() {

	# Colour definitions
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

	# Implementation of adding multiple colour codes with multiple strings
	# If an even number of arguments are provided and is greater than 4
	if [[ $(( $# % 2 )) -eq 0  && $# -ge 4 ]] ; then
		# Declaring local arrays for storing colours and strings
		local -a COLOUR
		local -a STRING

		# While the number of arguments is > 0
		while [[ $# -gt 0 ]] ; do
			case "$1" in
				# If "first" argument is either 'colour' or 'color'
				--colour|--color|-c)
					# Add the accompanying argument to variable $COLOUR
					if [[ "$2" =~ ^(blue|cyan|green|orange|purple|red|violet|white|yellow)$ ]] ; then
						COLOUR+=("${2^^}")  # Add colour to $COLOUR array and change colour name to uppercase
						shift 2             # Shift the first two arguments away : "--colour red" have been shifted away
					else
						printf '%s\n' "Incorrect colour option"
						print_help
						exit 1
					fi
				;;
				--string|-s)
					# If the string in the second argument is not empty
					if [[ -n "$2" ]] ; then
						STRING+=("$2")   # Add string to $STRING array
						shift 2          # Shift two arguments away: "--string "example" have been shifted away"
					# If the string provided is empty, print help text and exit
					else
						printf '%s\n' "Empty string provided. Check help text below"
						print_help
						exit 1
					fi
				;;
				# If any other argument is provided, then print help text and exit
				*)
					print_help
				;;
			esac
		done

		# Print the colourised text
		# Cycle through all indices of the $COLOUR and $STRING
		# arrays.
		#
		# seq 0 1 3 = 0 1 2 3
		# ${#STRING[@]} = Number of elements in $STRING array(which is equal to half of number of arguments)
		# which is equal to total number of times a string should be printed.
		# For each coloured string, there are two arguments provided.
		for ARGS in $( seq 0 1 $(( ${#STRING[@]} - 1 )) ) ; do
			printf '%s ' "${!COLOUR["${ARGS}"]}" "${STRING["${ARGS}"]}"
		done
	# If number of arguments is not even and are not greater than 4, print help text and exit
	else
		printf '%s\n' "Number of arguments provided = $#"
		printf '%s\n' "Number of arguments required = 4(atleast)"
		print_help
		exit 1
	fi

	# Unset case-insensitive matching in 'bash'
	# Case-sensitive matching is the default behaviour in 'bash'
	shopt -qu nocasematch
}

# Calling the 'colourise' function and passing all arguments to it
#colourise "$@"

# End of script
