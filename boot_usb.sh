#!/bin/bash

REPEAT_SEARCH=y
echo ""

# Creating temporary files to store transient information that the script needs
COMP1=$( mktemp img_burn_script.XXX ) || COMP1=$( mktemp img_burn_script&& )
COMP2=$( mktemp img_burn_script.XXX ) || COMP1=$( mktemp img_burn_script&& )
MOUNT1=$( mktemp img_burn_script.XXX ) || COMP1=$( mktemp img_burn_script&& )
MOUNT2=$( mktemp img_burn_script.XXX ) || COMP1=$( mktemp img_burn_script&& )


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
    echo "Searching for iso files containing the term "${SEARCH}"...."

    SEARCH_RESULTS="$(find "${HOME}" -maxdepth 4 -type f -name "*.iso" -and -iname "*${SEARCH}*" 2>/dev/null )"
    NUMBER=$(echo "${SEARCH_RESULTS}" | wc -l)

	FLAG=2

    while [ "${FLAG}" -ne 0 ]
	do
		while [ "${NUMBER}" -eq 1 ] && [ "$(echo "${SEARCH_RESULTS}" | wc -c )" -gt 2 ] && [ "${FLAG}" -ne 0 ]
		do        
			echo ""
			echo "The search result is :"
			echo "${SEARCH_RESULTS}" | nl -d"\n"
			echo ""

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
					echo ""
					echo "The file that you picked is : " ${ISO}
					FLAG=0
					REPEAT_SEARCH=n
				else
					read -p "Search for file again? (y -- yes ; n -- no) : " REPEAT_SEARCH

					if [ "${REPEAT_SEARCH}" = y ]
					then
						echo ""
						FLAG=0
					elif [ "${REPEAT_SEARCH}" = n ]
					then
						echo""
						echo "Program exited."
						FLAG=0
					fi
				fi
			done

			while [ "${FLAG}" -eq -1 ]
			do
				echo ""
				read -p "Invalid choice. Enter 's' to show file again : " PICK

				if [ "${PICK}" = s ]
				then
					FLAG=2
				fi
			done
		done

		while [ "${NUMBER}" -gt 1 ] && [ "$(echo "${SEARCH_RESULTS}" | wc -c)" -gt 2 ] && [ "${FLAG}" -ne 0 ]
		do
			echo ""
			echo "The search results are :"
			echo "${SEARCH_RESULTS}" | nl -d"\n"
			echo ""

			read -p "Enter the number that is against the file that you want to pick : " PICK

			if [ "${PICK}" -gt 0 ] && [ "${PICK}" -lt "$(expr ${NUMBER} + 1)" ]
			then
				FLAG=1
			else
				FLAG=-1
			fi

			while [ "${FLAG}" -eq 1 ]
			do
#				ISO="$( echo "${SEARCH_RESULTS}" | head -"${PICK}" | tail -1 )"
				ISO="$( echo "${SEARCH_RESULTS}" | sed -n "${PICK}"p )"
				echo ""
				echo "The file that you have picked is : " ${ISO}
				FLAG=0
				REPEAT_SEARCH=n
			done

			while [ "${FLAG}" -eq -1 ]
			do
				echo ""
				read -p "Invalid choice. Please enter the number that is against the file listed. Enter 's' to show list of files again : " PICK
				echo ""

				if [ "${PICK}" = s ]
				then
					FLAG=2
				fi
			done
		done

		while [ "${NUMBER}" -le 1 ] && [ "$(echo "${SEARCH_RESULTS}" | wc -c )" -le 2 ] && [ "${FLAG}" -ne 0 ]
		do
			echo ""
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
					echo ""
					echo "Program exited."
					FLAG=0
				fi
			done

			while [ "${FLAG}" -eq -1 ]
			do
				echo ""
				read -p "Invalid choice. Please enter 's' to show the previous menu : " REPEAT_SEARCH

				if [ "${REPEAT_SEARCH}" = s ]
				then
					FLAG=2
				fi
			done
		done
	done

        echo ""

	##################################### ISO to IMG Conversion Part ######################################

	echo "---------------------File Details-------------------" >>"${HOME}"/log_file.txt
	echo "The file that was picked : "${ISO}"." >>"${HOME}"/log_file.txt
	echo "The file details : " >>"${HOME}"/log_file.txt
	file "${ISO}" >>"${HOME}"/log_file.txt
	echo "----------------------------------------------------" >>"${HOME}"/log_file.txt

	echo "" | tee -a "${HOME}"/log_file.txt
	echo "-----------------File Conversion Process-----------------" | tee -a "${HOME}"/log_file.txt
	echo "" | tee -a "${HOME}"/log_file.txt

	if [ -f "${ISO}" ]
	then
		IMG="$( basename "${ISO}" | sed 's/.iso//g' ).img"
		echo "File conversion(from ISO to IMG) started." | tee -a "${HOME}"/log_file.txt
		hdiutil convert -format UDRW -o "${HOME}"/"${IMG}" "${ISO}" 2>&1 | tee -a "${HOME}"/log_file.txt 

		if [ -e "${HOME}"/"${IMG}".dmg ]		# If the .img.dmg file exists
		then
			echo "File conversion completed." | tee -a "${HOME}"/log_file.txt
			echo "" | tee -a "${HOME}"/log_file.txt
			mv -v "${HOME}"/"${IMG}".dmg "${HOME}"/"${IMG}" >> "${HOME}"/log_file.txt
		
			if [ -e "${HOME}"/"${IMG}" ]		# If the .img file exists
			then
				echo "The Linux ISO has been converted to IMG format." | tee -a "${HOME}"/log_file.txt
				echo "----------------------------------------------------" >>"${HOME}"/log_file.txt
				REPEAT_SEARCH=n
				FLAG=3
			fi
		else
			echo ""
			echo "The convert command might have failed or there is no .dmg file to convert to .img" | tee -a "${HOME}"/log_file.txt
			echo "----------------------------------------------------" >>"${HOME}"/log_file.txt
			REPEAT_SEARCH=n
			FLAG=-1
		fi
	else
		echo "The ISO file doesn't exist or the path provided is incorrect." | tee -a "${HOME}"/log_file.txt
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
			diskutil list > "${COMP1}" #"${HOME}"/comp_file1.txt
			mount > "${MOUNT1}" #"${HOME}"/mount_file1.txt
			FLAG=2
		else
			echo ""
			echo "Invalid key."
			echo ""
		fi
	done

	while [ "${FLAG}" -ne 1 ] && [ "${FLAG}" -eq 2 ]
	do
		read -p "Insert the pen-drive that is to be written to. Press 'y' and enter when done : " CONF

		if [ "${CONF}" = y ]
		then
			echo "Please wait. Recognising inserted drive..."
			sleep 4
			diskutil list > "${COMP2}" #"${HOME}"/comp_file2.txt
			mount > "${MOUNT2}" #"${HOME}"/mount_file2.txt
			FLAG=1
		else
			echo ""
			echo "Invalid key."
			echo ""
		fi
	done

	while [ "${FLAG}" -ne 0 ] && [ "${FLAG}" -eq 1 ]
	do
		DRIVE="$( diff $COMP1 $COMP2 | grep -i '/dev/' | cut -d" " -f2 )"						# /dev/disk2 type
		MOUNT_DISK="$( diff $MOUNT1 $MOUNT2 | grep -i '/dev/disk' | cut -d" " -f2 )"					# /dev/disk2s1 type
		MOUNT_DRIVE="$( diff $MOUNT1 $MOUNT2 | grep -i '/dev/disk' | cut -d" " -f4 | sed 's/\ /\\\ /g')"		# /Volumes/DRIVE type
		echo ""

		echo "The drive selected is '"${DRIVE}"' and is mounted at '"${MOUNT_DRIVE}"'."
		echo "The drive '"${DRIVE}"' mounted at '"${MOUNT_DRIVE}"' will be formatted to ExFAT with the name 'DRIVE'."
		read -p "Warning: The drive '"${DRIVE}"' will be erased completely. To proceed, press 'y'. To halt, press 'n' : " CONF

		if [ "${CONF}" = y ]
		then
			echo ""
			echo "Erasing and formatting disk '"${DRIVE}"'."
			diskutil eraseDisk ExFAT DRIVE "${DRIVE}" 2>&1 | tee -a "${HOME}"/log_file.txt
			echo "'"${DRIVE}"' has been erased and formatted to ExFAT with the name 'DRIVE'."
			echo "The disk will now be unmounted."
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
					
					echo "The drive '"${MOUNT_DRIVE}"' will be renamed to 'DRIVE'. No loss of data will occur. This is to help make the backup."
					diskutil rename "${MOUNT_DISK}" DRIVE >>"${HOME}"/log_file.txt 2>&1
					echo ""
					echo "Backing up the contents of the drive '"${DRIVE}"' to '"${HOME}"' under the filename 'backup.zip'." | tee >>"${HOME}"/log_file.txt
					echo "Depending upon the number and size of the files, this may take a while. Please wait."
					tar -cvpf - /Volumes/DRIVE 2>"${HOME}"/tar_logfile.txt | pv -tpreb >"${HOME}"/"${DRIVE_BACKUP}"

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
						echo ""
						echo "The files have been backed up."
						echo "To check the list of files that have been backed up, look at the 'tar_logfile.txt' in the home folder." | tee -a "${HOME}"/log_file.txt
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
							echo ""
							echo "Invalid key."
							echo""
						fi
					done
				else
					echo ""
					echo "Invalid key."
					echo ""

				fi
			done
		else
			echo ""
			echo "Invalid Key."
			echo""
		fi
	done

	while [ "${FLAG}" -ne 2 ] && [ "${FLAG}" -eq 0 ]
	do
		DRIVE_DD="$(echo "${DRIVE}" | sed 's/disk/rdisk/g')"

		echo "" ; echo ""
		echo "The Linux file will now be written to the the USB Drive. This will take a few minutes." ; sleep 2
		echo "After the USB has been written to, you may or may not get a prompt saying that the USB is not recognisable. If you do, click on 'Ignore'."; sleep 2
		
		if [ $(whoami) != "root" ]
		then
			echo "You will be prompted for the administrator/root password for the next step." ; sleep 2
		fi

		echo ""

		if [ -e "${HOME}"/"${IMG}" ]
		then
			echo "Starting write. This may take a while. Please wait...."
			
			if [ $(uname) == "Darwin" ]
			then
				( pv -tpreb "${HOME}"/"${IMG}" | sudo /bin/dd of="${DRIVE_DD}" bs=4m && sync ) | tee -a "${HOME}"/log_file.txt # bs=4m for BSD 'dd'
			else
				( pv -tpreb "${HOME}"/"${IMG}" | sudo dd of="${DRIVE_DD}" bs=4M && sync ) | tee -a "${HOME}"/log_file.txt	# bs=4M for GNU 'dd'
			fi

			if [[ $? -eq 0 ]]
			then
				echo "Writing to USB completed." | tee -a "${HOME}"/log_file.txt
				FLAG=0
			else
				echo "The write process encountered some issue." | tee -a "${HOME/log_file.txt}"
				echo "Check log-file for more information."
			fi
		else
			echo "The .img file that is to be written to the disk could not be found."
			FLAG=-1
			echo "Process stopped."
		fi

		if [ "${FLAG}" -eq 0 ]
		then		
			diskutil eject "${DRIVE}" >>"${HOME}"/log_file.txt 2>&1
			rm "${COMP1}" "${COMP2}" "${MOUNT1}" "${MOUNT2}" "${HOME}"/"${IMG}"
			echo "The USB has been ejected. The process is done."
			FLAG=-1
		fi
	done
done

# End of script
