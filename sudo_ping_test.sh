#!/bin/bash

TEMP=""

dialog --backtitle "Raspberry Pi Image Burner V0.1_alpha" --title "Authentication required" \
	--passwordbox "[sudo] Password for user $USER : " 0 0 2>TEMP

printf "%s\n" "${TEMP}" #| ( sudo -S sudo su - ) && sudo ping -f 8.8.8.8
