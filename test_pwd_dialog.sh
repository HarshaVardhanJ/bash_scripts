#!/bin/bash

TEMP=$( mktemp -t rpi ) || TEMP=$( mktemp rpi&& )
IMG="$( ls ~/Downloads/Linux\ ISOs/Fedora*)"
#SIZE="$( du -hd1 "${IMG}" | cut -d"/" -f1 | tr -d "[:space:]" )"
DRIVE="$( echo '/dev/disk2' )"
DRIVE_DD="$( echo ""${DRIVE}"" | sed 's/disk/rdisk/g' )"
#diskutil eraseDisk FAT32 DRIVE "${DRIVE}"
diskutil unmountDisk "${DRIVE}"

display_gauge () # Displaying a box with a gauge to show progress
{
	dialog --no-collapse --clear --backtitle "Raspberry Pi Image Burner V0.1_alpha" --gauge "$1" 10 50
}

dd_gauge()
{
	( pv -tprenW "${IMG}" | sudo dd of="${DRIVE_DD}" bs=4m && sync ) 2>&1 | display_gauge "Writing to "${DRIVE}"."
}

if [[ whoami != root ]]
then
 	sudo -k
 	dialog --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "Authentication required" --passwordbox "[sudo] Password for user $USER : " 0 0 2>"${TEMP}" && echo -e "\n" >>"${TEMP}"

	( cat "${TEMP}" | sudo -S sudo su ) && ( pv -nW "${IMG}" | sudo dd of="${DRIVE_DD}" bs=4m && sync ) 2>&1 | display_gauge "Writing to "${DRIVE}"." #dialog --clear --gauge "Writing to "${DRIVE}"." 10 60

	sudo -k
	whoami
elif [[ whoami == root ]]
then
	dd_gauge
fi

rm -fv "${TEMP}"

# Comments :
