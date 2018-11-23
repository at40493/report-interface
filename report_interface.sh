#!/bin/sh



get_interface_bytes(){

	name=$1
	type=$2
	# Get the interface information.
	interface_info=$(ifconfig "${name}")
	# Check the interface name.
	if [ -z "${interface_info}" ]; then
		# The interface is not exist.
		return 1
	fi 
	# Get the number of bytes.
	if [ "${type}" = "RX" ]; then
		# RX bytes
		echo "${interface_info}" | grep bytes | awk '{print $2}' | awk -F : '{print $2}'
	elif [ "${type}" = "TX" ]; then
		# TX bytes
		echo "${interface_info}" | grep bytes | awk '{print $6}' | awk -F : '{print $2}'
	else
		echo "get_interface_bytes() error: the type must be RX or TX." 1>&2
		return 1
	fi
	
	return 0
}

usage(){
	printf "USAGE: ./report_interface.sh -i interface name [-t time(s)]\n\n"
	echo "REQUIED:"
	printf "\t -i interface name -  the names of the active network interfaces on the system\n\n"
	echo "OPTINAL:"
	printf "\t -t time(s) -  the time interval of report packets.(Default: 1 sec)\n\n"
}

while getopts "i:t:" opt; do 

	case ${opt} in
	i) # -i interface_name  
		interface_name=$OPTARG;;
	t) # -t interval_time
		interval_time=$OPTARG;;
	?) 
		usage
		exit 1
	esac
done


#Check the input format
if [ -z "${interface_name}" ]; then
	usage
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
rx_previous=$(get_interface_bytes "${interface_name}" "RX")
# Get interface bytes failed.
if [ -z "${rx_previous}" ]; then
	exit 1
fi
tx_previous=$(get_interface_bytes "${interface_name}" "TX")
# Get interface bytes failed.
if [ -z "${tx_previous}" ]; then
	exit 1
fi


# Show the number of packet.
while [ 1 ]; 
do
	# The interval time
	sleep "${interval_time}"
	# Get the number of packets. 
	rx_current=$(get_interface_bytes "${interface_name}" "RX")
	# Get interface bytes failed.
	if [ -z "${rx_current}" ]; then
		exit 1
	fi
	tx_current=$(get_interface_bytes "${interface_name}" "TX")
	# Get interface bytes failed.
	if [ -z "${tx_current}" ]; then
		exit 1
	fi
	# Subtract previous bytes from current bytes.
	rx_sub=$(((rx_current - rx_previous)/interval_time))
	tx_sub=$(((tx_current - tx_previous)/interval_time))
	# Show the output.
	echo "RX: ${rx_sub}  	Bytes/s 	TX: ${tx_sub}	Bytes/s"
	# store the number of bytes.
	rx_previous="${rx_current}"
	tx_previous="${tx_current}"
	
done
