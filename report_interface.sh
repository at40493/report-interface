#!/bin/sh

interface_name=$1
interval_time=$2

#Check the input format
if [ -z ${interface_name} ]; then
	printf "USAGE: ./report_interface.sh [interface name] [time(s)]\n\n"
	echo "REQUIED:"
	printf "\t interface name -  the names of the active network interfaces on the system\n\n"
	echo "OPTINAL:"
	printf "\t time(s) -  the time interval of report packets.(Default: 1 sec)\n\n"
	exit 1
fi

# Default time value.
if [ -z ${interval_time} ]; then
	interval_time=1; # Set 1 sec.
fi

# Check the delay time is number.
if [ -z $(echo ${interval_time} | sed -n "/^[+-]\?[0-9]\+$/p") ]; then
	echo "${interval_time} is not a number."
	exit 1
fi

# Check the delay time is bigger than 1.
if [ ${interval_time} -lt 1 ]; then
	echo "${interval_time} is less than 1."
	exit 1
fi

# Get RX and TX packets information.
packet_info_pre=`ifconfig ${interface_name} | grep packets`
# Check the interface name is exist.
if [ $? -ne 0 ]; then
	# The interface is not exist.
	exit 1
fi 
	
# The number of previous packet.
rx_previous=`echo ${packet_info_pre} | awk '{print $2}' | awk -F : '{print $2}'`
tx_previous=`echo ${packet_info_pre} | awk '{print $8}' | awk -F : '{print $2}'`


while [ 1 ]; do
	# The interval time
	sleep ${interval_time}
	# Get RX and TX packets information.
	packet_info=`ifconfig ${interface_name} | grep packets`
	# Get the number of packets. 
	rx_current=`echo ${packet_info} | awk '{print $2}' | awk -F : '{print $2}'`
	tx_current=`echo ${packet_info} | awk '{print $8}' | awk -F : '{print $2}'`
	# Subtract previous packets from current packets.
	rx_sub=`expr ${rx_current} - ${rx_previous}`
	tx_sub=`expr ${tx_current} - ${tx_previous}`
	# Show the output.
	echo "RX packets: ${rx_sub}	 TX packets: ${tx_sub} "
	# store the number of packets.
	rx_previous=${rx_current}
	tx_previous=${tx_current}
done

