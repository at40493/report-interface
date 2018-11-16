#!/bin/bash

#Check the input format
if [ -z "$1" -o -z "$2" ];
then
	echo "Not enough argument."
	echo "USAGE: ./report_interface.sh [interface name] [time(s)]"
	exit 0
fi


interface_name=$1
# Check the interface name is exist.
ifconfig ${interface_name} > /dev/null
if [ $? -ne 0 ]; 
then
	# The interface is not exist.
	exit 0
fi 

delay_time=$2
# Check the delay time is number.
if [[ ! ${delay_time} =~ ^[0-9]+$ ]];
then
	echo "The time is not a number."
	exit 0;
fi

# Check the delay time is bigger than 0.
if [ ${delay_time} -lt 0 ]; 
then
	echo "Time is negative, it must > 0."
	exit 0;
fi

# Show the number of packet.
while [ 1 ]; 
do
	grep ${interface_name} /proc/net/dev| awk '{printf("RX packets: %s TX packets: %s \r"),$3,$11}'
	sleep ${delay_time}
done
