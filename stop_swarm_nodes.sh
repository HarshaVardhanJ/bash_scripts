#!/bin/bash
############################################################
#                                                          # 
#             Maintainer: Harsha Vardhan J                 #
#                                                          #
#    bash script for stopping all machines started by      #
#              'docker-machine' command.                   #
#                                                          #
############################################################

ARRAY=($(docker-machine ls | grep -v "NAME" | grep -v "machine does not exist" | grep "Running" | awk '{print $1}'))

for MACHINE in "${ARRAY[@]}"
do
	docker-machine stop "${MACHINE}"
done
