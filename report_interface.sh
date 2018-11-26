#!/bin/sh



get_interface_info(){

	name=$1
	# Get the interface information.
	interface_info=$(ifconfig "${name}")
	# Check the interface name.
	if [ -z "${interface_info}" ]; then
		# The interface is not exist.
		return 1
	fi 
	
	echo "${interface_info}"
	return 0
}

# The message block.
: <<ENDOFUSAGE

USAGE: 
	./report_interface.sh -i interface name [-t time(s)]
REQUIED:
	-i interface name -  the names of the active network interfaces on the system
OPTINAL:
	-t time(s) -  the time interval of report packets.(Default: 1 sec)

ENDOFUSAGE

while getopts "i:t:" opt; do 

	case ${opt} in
	i) # -i interface_name  
		interface_name=$OPTARG
		;;
	t) # -t interval_time
		interval_time=$OPTARG
		;;
	?) 
		# Show the usage message.
		sed -n -e '/ENDOFUSAGE$/,/^ENDOFUSAGE$/p' "$0" | sed -e '/ENDOFUSAGE$/d';
		exit 1
	esac
done

# There are no any arguments.
if [ $# -eq 0 ]; then
	# Show the usage message.
	sed -n -e '/ENDOFUSAGE$/,/^ENDOFUSAGE$/p' "$0" | sed -e '/ENDOFUSAGE$/d';
	exit 1
fi

#Check the input format
if [ -z "${interface_name}" ]; then
	echo "The interface name is null."
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


# Get the previous interface information.
interface_info_pre=$(get_interface_info "${interface_name}")
# Get the interface information failed.
if [ -z "${interface_info_pre}" ]; then
	exit 1
fi
# The number of previous packet.
rx_previous=$(echo "${interface_info_pre}" | grep bytes | awk '{print $2}' | awk -F : '{print $2}')
# Get interface bytes failed.
if [ -z "${rx_previous}" ]; then
	exit 1
fi
tx_previous=$(echo "${interface_info_pre}" | grep bytes | awk '{print $6}' | awk -F : '{print $2}')
# Get interface bytes failed.
if [ -z "${tx_previous}" ]; then
	exit 1
fi


# Show the number of packet.
while  true; do
	# The interval time
	sleep "${interval_time}"
	# Get the current interface information.
	interface_info_cur=$(get_interface_info "${interface_name}")
	# Get the interface information failed.
	if [ -z "${interface_info_cur}" ]; then
		exit 1
	fi
	# Get the number of packets. 
	rx_current=$(echo "${interface_info_cur}"  | grep bytes | awk '{print $2}' | awk -F : '{print $2}')
	# Get interface bytes failed.
	if [ -z "${rx_current}" ]; then
		exit 1
	fi
	tx_current=$(echo "${interface_info_cur}"  | grep bytes | awk '{print $6}' | awk -F : '{print $2}')
	# Get interface bytes failed.
	if [ -z "${tx_current}" ]; then
		exit 1
	fi
	# Subtract previous bytes from current bytes.
	rx_sub=$(((rx_current - rx_previous)/interval_time))
	tx_sub=$(((tx_current - tx_previous)/interval_time))
	# Show the output.
	printf "RX (bytes/s): %d \t TX (bytes/s): %d\n" "${rx_sub}" "${tx_sub}"
	# store the number of bytes.
	rx_previous="${rx_current}"
	tx_previous="${tx_current}"
	
done
