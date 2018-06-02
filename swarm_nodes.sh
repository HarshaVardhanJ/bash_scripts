#!/bin/bash
############################################################
#                                                          # 
#             Maintainer: Harsha Vardhan J                 #
#                                                          #
#    bash script for starting and stopping all machines    #
#          created by 'docker-machine' command.            #
#                                                          #
############################################################

ARG="$1"

case "${ARG}" in
	start)
		ARRAY=($(docker-machine ls | grep -v "NAME" | grep -v "machine does not exist" | grep "Stopped" | awk '{print $1}'))
		printf "\nStarting nodes...\n"
		for MACHINE in "${ARRAY[@]}"
		do
			docker-machine stop "${MACHINE}"
		done
		;;
	stop)
		ARRAY=($(docker-machine ls | grep -v "NAME" | grep -v "machine does not exist" | grep "Running" | awk '{print $1}'))
		printf "\nStopping nodes...\n"
		for MACHINE in "${ARRAY[@]}"
		do
			docker-machine start "${MACHINE}"
		done
		;;
	--help|-h|help|?)
		printf "\nThis script accepts either 'start' or 'stop' as arguments on which it performs actions.\n\
			\n\t'start' --->\tThe script proceeds to start all the machines listed by 'docker-machine ls' \
			\n\t\t\tthat are in stopped state.\n\
			\n\t'stop'\t--->\tThe script proceeds to stop all the machines listend by 'docker-machine ls' \
			\n\t\t\tthat are in running state.\n\
			\n\t'help'\t--->\tThe script displays this usage message.\n"
		;;
esac
