#!/bin/bash

REPEAT_SEARCH=y
printf ""

# Creating temporary files to store transient information that the script needs
COMP1=$( mktemp img_burn_script.XXX ) #|| COMP1=$( mktemp img_burn_script&& )
COMP2=$( mktemp img_burn_script.XXX ) #|| COMP1=$( mktemp img_burn_script&& )
MOUNT1=$( mktemp img_burn_script.XXX ) #|| MOUNT1=$( mktemp img_burn_script&& )
MOUNT2=$( mktemp img_burn_script.XXX ) #|| MOUNT2=$( mktemp img_burn_script&& )

DATE="$( date "+%Y-%m-%d@%H:%M:%S" )"
DRIVE_BACKUP="Backup("${DATE}").tar"
HOME="$( ls -d ~ )"

# Function to delete all created temporary files and .img file
function finish
{
	for FILE in "${MOUNT1}" "${MOUNT2}" "${COMP1}" "${COMP2}" "${HOME}"/"${IMG}"
	do
		if [ -e "${FILE}" ]
		then
			cd $( dirname "${FILE}" ) && rm -rv $( basename "${FILE}" ) 2>&1 | tee -a "${HOME}"/log_file.txt
		fi
	done
}

# Trapping script exit(0), SIGHUP(1), SIGINT(2), SIGQUIT(3), SIGTRAP(5), SIGTERM(15)
trap finish 0 1 2 3 5 15

while [ ${REPEAT_SEARCH} = y ]
do
    read -p "Enter a name of an iso file to search for : " SEARCH
    printf "Searching for iso files containing the term "${SEARCH}"...."

    SEARCH_RESULTS="$(find "${HOME}" -maxdepth 4 -type f -name "*.iso" -and -iname "*${SEARCH}*" 2>/dev/null )"
    NUMBER=$(printf "${SEARCH_RESULTS}" | wc -l)

	FLAG=2

    while [ "${FLAG}" -ne 0 ]
	do
		while [ "${NUMBER}" -eq 1 ] && [ "$(printf "${SEARCH_RESULTS}" | wc -c )" -gt 2 ] && [ "${FLAG}" -ne 0 ]
		do        
			printf ""
			printf "The search result is :"
			printf "${SEARCH_RESULTS}" | nl -d"\n"
			printf ""

			read -p "Single iso file found containing the term '${SEARCH}'. Pick this file? (y -- yes ; n -- no) : " PICK
			
			if [ "${PICK}" = y ] || [ "${PICK}" = n ]
			then
				FLAG=1
			else
				FLAG=-1
			fi

			while [ "${FLAG}" -eq 1 ]
			do
				if [ "${PICK}" = y ]
				then
					ISO="${SEARCH_RESULTS}"
					printf ""
					printf "The file that you picked is : " ${ISO}
					FLAG=0
					REPEAT_SEARCH=n
				else
					read -p "Search for file again? (y -- yes ; n -- no) : " REPEAT_SEARCH

					if [ "${REPEAT_SEARCH}" = y ]
					then
						printf ""
						FLAG=0
					elif [ "${REPEAT_SEARCH}" = n ]
					then
						printf""
						printf "Program exited."
						FLAG=0
					fi
				fi
			done

			while [ "${FLAG}" -eq -1 ]
			do
				printf ""
				read -p "Invalid choice. Enter 's' to show file again : " PICK

				if [ "${PICK}" = s ]
				then
					FLAG=2
				fi
			done
		done

		while [ "${NUMBER}" -gt 1 ] && [ "$(printf "${SEARCH_RESULTS}" | wc -c)" -gt 2 ] && [ "${FLAG}" -ne 0 ]
		do
			printf ""
			printf "The search results are :"
			printf "${SEARCH_RESULTS}" | nl -d"\n"
			printf ""

			read -p "Enter the number that is against the file that you want to pick : " PICK

			if [ "${PICK}" -gt 0 ] && [ "${PICK}" -lt "$(expr ${NUMBER} + 1)" ]
			then
				FLAG=1
			else
				FLAG=-1
			fi

			while [ "${FLAG}" -eq 1 ]
			do
 #				ISO="$( printf "${SEARCH_RESULTS}" | head -"${PICK}" | tail -1 )"
				ISO="$( printf "${SEARCH_RESULTS}" | sed -n "${PICK}"p )"
				printf ""
				printf "The file that you have picked is : " ${ISO}
				FLAG=0
				REPEAT_SEARCH=n
			done

			while [ "${FLAG}" -eq -1 ]
			do
				printf ""
				read -p "Invalid choice. Please enter the number that is against the file listed. Enter 's' to show list of files again : " PICK
				printf ""

				if [ "${PICK}" = s ]
				then
					FLAG=2
				fi
			done
		done

		while [ "${NUMBER}" -le 1 ] && [ "$(printf "${SEARCH_RESULTS}" | wc -c )" -le 2 ] && [ "${FLAG}" -ne 0 ]
		do
			printf ""
			read -p "No iso file found containing the term '${SEARCH}'. Search for a different file? (y -- yes ; n -- no) : " REPEAT_SEARCH
			
			if [ "${REPEAT_SEARCH}" = y ] || [ "${REPEAT_SEARCH}" = n ]
			then
				FLAG=1
			else
				FLAG=-1
			fi

			while [ "${FLAG}" -eq 1 ]
			do
				if [ "${REPEAT_SEARCH}" = y ]
				then
					FLAG=0
				elif [ "${REPEAT_SEARCH}" = n ]
				then
					printf ""
					printf "Program exited."
					FLAG=0
				fi
			done

			while [ "${FLAG}" -eq -1 ]
			do
				printf ""
				read -p "Invalid choice. Please enter 's' to show the previous menu : " REPEAT_SEARCH

				if [ "${REPEAT_SEARCH}" = s ]
				then
					FLAG=2
				fi
			done
		done
	done

        printf ""

	##################################### ISO to IMG Conversion Part ######################################

	printf "---------------------File Details-------------------" >>"${HOME}"/log_file.txt
	printf "The file that was picked : "${ISO}"." >>"${HOME}"/log_file.txt
	printf "The file details : " >>"${HOME}"/log_file.txt
	file "${ISO}" >>"${HOME}"/log_file.txt
	printf "----------------------------------------------------" >>"${HOME}"/log_file.txt

	printf "" | tee -a "${HOME}"/log_file.txt
	printf "-----------------File Conversion Process-----------------" | tee -a "${HOME}"/log_file.txt
	printf "" | tee -a "${HOME}"/log_file.txt

	if [ -f "${ISO}" ]
	then
		IMG="$( basename "${ISO}" | sed 's/.iso//g' ).img"
		printf "File conversion(from ISO to IMG) started." | tee -a "${HOME}"/log_file.txt
		hdiutil convert -format UDRW -o "${HOME}"/"${IMG}" "${ISO}" 2>&1 | tee -a "${HOME}"/log_file.txt 

		if [ -e "${HOME}"/"${IMG}".dmg ]		# If the .img.dmg file exists
		then
			printf "File conversion completed." | tee -a "${HOME}"/log_file.txt
			printf "" | tee -a "${HOME}"/log_file.txt
			mv -v "${HOME}"/"${IMG}".dmg "${HOME}"/"${IMG}" >> "${HOME}"/log_file.txt
		
			if [ -e "${HOME}"/"${IMG}" ]		# If the .img file exists
			then
				printf "The Linux ISO has been converted to IMG format." | tee -a "${HOME}"/log_file.txt
				printf "----------------------------------------------------" >>"${HOME}"/log_file.txt
				REPEAT_SEARCH=n
				FLAG=3
			fi
		else
			printf ""
			printf "The convert command might have failed or there is no .dmg file to convert to .img" | tee -a "${HOME}"/log_file.txt
			printf "----------------------------------------------------" >>"${HOME}"/log_file.txt
			REPEAT_SEARCH=n
			FLAG=-1
		fi
	else
		printf "The ISO file doesn't exist or the path provided is incorrect." | tee -a "${HOME}"/log_file.txt
		REPEAT_SEARCH=n
		FLAG=-1
	fi
done

cd "${HOME}"
#FLAG=3

##################################### DD to USB Part ###################################### 

while [ "${FLAG}" -ne -1 ]
do
	while [ "${FLAG}" -ne 2 ] && [ "${FLAG}" -eq 3 ]
	do
		read -p "If the pen-drive is attached to the computer, please remove it. Press 'y' and enter when done : " CONF

		if [ "${CONF}" = y ]
		then
			diskutil list > "${COMP1}"
			mount > "${MOUNT1}"
			FLAG=2
		else
			printf ""
			printf "Invalid key."
			printf ""
		fi
	done

	while [ "${FLAG}" -ne 1 ] && [ "${FLAG}" -eq 2 ]
	do
		read -p "Insert the pen-drive that is to be written to. Press 'y' and enter when done : " CONF

		if [ "${CONF}" = y ]
		then
			printf "Please wait. Recognising inserted drive..."
			sleep 4
			diskutil list > "${COMP2}"
			mount > "${MOUNT2}"
			FLAG=1
		else
			printf ""
			printf "Invalid key."
			printf ""
		fi
	done

	while [ "${FLAG}" -ne 0 ] && [ "${FLAG}" -eq 1 ]
	do
		DRIVE="$( diff $COMP1 $COMP2 | grep -i '/dev/' | cut -d" " -f2 )"									# /dev/disk2 type
		MOUNT_DISK="$( diff $MOUNT1 $MOUNT2 | grep -i '/dev/disk' | cut -d" " -f2 )"						# /dev/disk2s1 type
		MOUNT_DRIVE="$( diff $MOUNT1 $MOUNT2 | grep -i '/dev/disk' | cut -d" " -f4 | sed 's/\ /\\\ /g')"	# /Volumes/DRIVE type
		printf ""

		printf "The drive selected is '"${DRIVE}"' and is mounted at '"${MOUNT_DRIVE}"'."
		printf "The drive '"${DRIVE}"' mounted at '"${MOUNT_DRIVE}"' will be formatted to ExFAT with the name 'DRIVE'."
		read -p "Warning: The drive '"${DRIVE}"' will be erased completely. To proceed, press 'y'. To halt, press 'n' : " CONF

		if [ "${CONF}" = y ]
		then
			printf ""
			printf "Erasing and formatting disk '"${DRIVE}"'."
			diskutil eraseDisk ExFAT DRIVE "${DRIVE}" 2>&1 | tee -a "${HOME}"/log_file.txt
			printf "'"${DRIVE}"' has been erased and formatted to ExFAT with the name 'DRIVE'."
			printf "The disk will now be unmounted."
			diskutil unmountDisk "${DRIVE}" 2>&1 | tee -a "${HOME}"/log_file.txt
			FLAG=0
		elif [ "${CONF}" = n ]
		then
			STORE_CONF=z
			while [ "${STORE_CONF}" != "y" ] && [ "${STORE_CONF}" != "n" ]
			do
				read -p "Halting process. Do you want to backup the contents of the drive to this computer? (y/n) : " STORE_CONF

				if [ "${STORE_CONF}" = y ]
				then
					
					printf "The drive '"${MOUNT_DRIVE}"' will be renamed to 'DRIVE'. No loss of data will occur. This is to help make the backup."
					diskutil rename "${MOUNT_DISK}" DRIVE >>"${HOME}"/log_file.txt 2>&1
					printf ""
					printf "Backing up the contents of the drive '"${DRIVE}"' to '"${HOME}"' under the filename 'backup.zip'." | tee >>"${HOME}"/log_file.txt
					printf "Depending upon the number and size of the files, this may take a while. Please wait."

					read -p "Would you like to compress the backup file to save disk space on your machine? \n \
						Compression is processor intensive and will take longer. Compress backup? (y/n) : " COMPRESS

					if [ "${COMPRESS}" = y ]	# If user wants backup file to be compressed
					then
						tar -cvpzf - /Volumes/DRIVE 2>"${HOME}"/tar_logfile.txt | pv -tpreb >"${HOME}"/""${DRIVE_BACKUP}".gz"
					elif [ "${COMPRESS}" = n ]	# If user doesn't want backup file to be compressed
					then
						tar -cvpf - /Volumes/DRIVE 2>"${HOME}"/tar_logfile.txt | pv -tpreb >"${HOME}"/"${DRIVE_BACKUP}"
					fi


					if [ -e "${HOME}"/""${DRIVE_BACKUP}".gz" || -e "${HOME}"/"${DRIVE_BACKUP}" ] && [ $? == 0 ]
					then
						printf ""
						printf "The files have been backed up."
						printf "To check the list of files that have been backed up, look at the 'tar_logfile.txt' in the home folder." | tee -a "${HOME}"/log_file.txt
					fi
				elif [ "${STORE_CONF}" = n ]
				then
					while [ "${CONF}" != "x" ] && [ "${CONF}" != "y" ]
					do
						read -p "Files will not be backed up. (x--exit process ; y--reselect drive) : " CONF

						if [ "${CONF}" = x ]
						then
							FLAG=-1
						elif [ "${CONF}" = y ]
						then
							FLAG=3
						else
							printf ""
							printf "Invalid key."
							printf""
						fi
					done
				else
					printf ""
					printf "Invalid key."
					printf ""

				fi
			done
		else
			printf ""
			printf "Invalid Key."
			printf""
		fi
	done

	while [ "${FLAG}" -ne 2 ] && [ "${FLAG}" -eq 0 ]
	do
		DRIVE_DD="$(printf "${DRIVE}" | sed 's/disk/rdisk/g')"

		printf "" ; printf ""
		printf "The Linux file will now be written to the the USB Drive. This will take a few minutes." ; sleep 2
		printf "After the USB has been written to, you may or may not get a prompt saying that the USB is not recognisable. If you do, click on 'Ignore'."; sleep 2
		
		if [ $(whoami) != "root" ]
		then
			printf "You will be prompted for the administrator/root password for the next step." ; sleep 2
		fi

		printf ""

		if [ -e "${HOME}"/"${IMG}" ]
		then
			printf "Starting write. This may take a while. Please wait...."
			
			if [ $(uname) == "Darwin" ]
			then
				( pv -tpreb "${HOME}"/"${IMG}" | sudo /bin/dd of="${DRIVE_DD}" bs=4m && sync ) | tee -a "${HOME}"/log_file.txt	# bs=4m for BSD 'dd'
			else
				( pv -tpreb "${HOME}"/"${IMG}" | sudo dd of="${DRIVE_DD}" bs=4M && sync ) | tee -a "${HOME}"/log_file.txt		# bs=4M for GNU 'dd'
			fi

			if [[ $? -eq 0 ]]
			then
				printf "Writing to USB completed." | tee -a "${HOME}"/log_file.txt
				FLAG=0
			else
				printf "The write process encountered some issue." | tee -a "${HOME/log_file.txt}"
				printf "Check log-file for more information."
			fi
		else
			printf "The .img file that is to be written to the disk could not be found."
			FLAG=-1
			printf "Process stopped."
		fi

		if [ "${FLAG}" -eq 0 ]
		then		
			diskutil eject "${DRIVE}" >>"${HOME}"/log_file.txt 2>&1
			printf "The USB has been ejected. The process is done."
			FLAG=-1
		fi
	done
done

# End of script
