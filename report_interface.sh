#!/bin/sh

interface_name=$1
interval_time=$2


get_packets_number(){

	name=$1
	type=$2
	# Get the interface information.
	interface_info=$(ifconfig "${name}")
	# Check the interface name.
	if [ -z "${interface_info}" ]; then
		# The interface is not exist.
		return 1
	fi 
	# Get the number of packets.
	echo "${interface_info}" | grep packets | grep "${type}" | awk '{print $2}' | awk -F : '{print $2}'
	return 0
}

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



	
# The number of previous packet.
rx_previous=$(get_packets_number "${interface_name}" "RX")
# Get packet information failed.
if [ -z "${rx_previous}" ]; then
	# The interface is not exist.
	exit 1
fi
tx_previous=$(get_packets_number "${interface_name}" "TX")



# Show the number of packet.
while [ 1 ]; 
do
	# The interval time
	sleep "${interval_time}"
	# Get the number of packets. 
	rx_current=$(get_packets_number "${interface_name}" "RX")
	tx_current=$(get_packets_number "${interface_name}" "TX")
	# Subtract previous packets from current packets.
	rx_sub=$((rx_current - rx_previous))
	tx_sub=$((tx_current - tx_previous))
	# Show the output.
	echo "RX packets: ${rx_sub}	 TX packets: ${tx_sub} "
	# store the number of packets.
	rx_previous="${rx_current}"
	tx_previous="${tx_current}"
	
done
