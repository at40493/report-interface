#!/bin/bash

interface_name=$1
interval_time=$2

#Check the input format
if [ -z "${interface_name}" ]; then
	printf "USAGE: ./report_interface.sh interface name [time(s)]\n\n"
	echo "REQUIED:"
	printf "\t interface name -  the names of the active network interfaces on the system\n\n"
	echo "OPTINAL:"
	printf "\t time(s) -  the time interval of report packets.(Default: 1 sec)\n\n"
	exit 1
fi

# Default time value.
if [ -z "${interval_time}" ]; then
	interval_time=1; # Set 1 sec.
fi

# Check the interval time is number.
if [ -z "$(echo "${interval_time}" | sed -n "/^[+-]\?[0-9]\+$/p")" ]; then
	echo "${interval_time} is not a number."
	exit 1
fi

# Check the interval time is bigger than 1.
if [ "${interval_time}" -lt 1 ]; then
	echo "${interval_time} is less than 1."
	exit 1
fi

# Check the interface name is exist.
ifconfig ${interface_name} > /dev/null
if [ $? -ne 0 ]; 
then
	# The interface is not exist.
	exit 0
fi 


# Show the number of packet.
while [ 1 ]; 
do
	grep ${interface_name} /proc/net/dev| awk '{printf("RX packets: %s TX packets: %s \r"),$3,$11}'
	sleep ${interval_time}
done
