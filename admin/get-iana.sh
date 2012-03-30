#!/bin/bash

#
# Program that downloads the IPv4 address space allocation by IANA
# and creates a list with all reserved address spaces.
#

# IPV4_ADDRESS_SPACE_URL="http://www.iana.org/assignments/ipv4-address-space"
IPV4_ADDRESS_SPACE_URL="http://www.iana.org/assignments/ipv4-address-space/ipv4-address-space.txt"

# The program will match all rows in the file which start with a number, have a slash,
# followed by another number, for which the following pattern will also match on the
# same rows
IANA_RESERVED="(RESERVED|UNALLOCATED)"

# which rows that are matched by the above, to ignore
# (i.e. not include them in RESERVED_IPS)?
#IANA_IGNORE="(Multicast|Private use|Loopback|Local Identification)"
IANA_IGNORE="Multicast"

tempfile="/tmp/iana.$$.$RANDOM"

AGGREGATE="`which aggregate-flim 2>/dev/null`"
if [ -z "${AGGREGATE}" ]
then
	AGGREGATE="`which aggregate 2>/dev/null`"
fi

if [ -z "${AGGREGATE}" ]
then
	echo >&2
	echo >&2
	echo >&2 "WARNING"
	echo >&2 "Please install 'aggregate-flim' or 'aggregate' to shrink the list of IPs."
	echo >&2
	echo >&2
fi

echo >&2
echo >&2 "Fetching IANA IPv4 Address Space, from:"
echo >&2 "${IPV4_ADDRESS_SPACE_URL}"
echo >&2

wget -O - "${IPV4_ADDRESS_SPACE_URL}"	|\
	egrep "^ *[0-9]+/[0-9]+.*${IANA_RESERVED}"	|\
	egrep -vi "${IANA_IGNORE}"			|\
	sed -e 's:^ *\([0-9]*/[0-9]*\).*:\1:'           |\
(
	while IFS="/" read range net
	do
		# echo >&2 "$range/$net"
		
		if [ ! $net -eq 8 ]
		then
			echo >&2 "Cannot handle network masks of $net bits ($range/$net)"
			continue
		fi

		first=`echo $range | cut -d '-' -f 1`
		first=`expr $first + 0`
		last=`echo $range | cut -d '-' -f 2`
		if [ "$last" = "" ]
		then
			last=$first
		fi
		last=`expr $last + 0`

		x=$first
		while [ ! $x -gt $last ]
		do
			test $x -ne 10 && echo "$x.0.0.0/$net"
			x=`expr $x + 1`
		done
	done
) | \
(
	if [ ! -z "${AGGREGATE}" -a -x "${AGGREGATE}" ]
	then
		"${AGGREGATE}"
	else
		cat
	fi
) >"${tempfile}"

echo >&2 
echo >&2 
echo >&2 "FOUND THE FOLLOWING RESERVED IP RANGES:"
printf "RESERVED_IPS=\""
i=0
for x in `cat ${tempfile}`
do
	i=`expr $i + 1`
	printf "${x} "
done
printf "\"\n"

if [ $i -eq 0 ]
then
	echo >&2 
	echo >&2 
	echo >&2 "Failed to find reserved IPs."
	echo >&2 "Possibly the file format has been changed, or I cannot fetch the URL."
	echo >&2 
	
	rm -f ${tempfile}
	exit 1
fi
echo >&2
echo >&2
echo >&2 "Differences between the fetched list and the list installed in"
echo >&2 "/etc/firehol/RESERVED_IPS:"

echo >&2 "# diff /etc/firehol/RESERVED_IPS ${tempfile}"
diff /etc/firehol/RESERVED_IPS ${tempfile}

if [ $? -eq 0 ]
then
	echo >&2
	echo >&2 "No differences found."
	echo >&2
	
	rm -f ${tempfile}
	exit 0
fi

echo >&2 
echo >&2 
echo >&2 "Would you like to save this list to /etc/firehol/RESERVED_IPS"
echo >&2 "so that FireHOL will automatically use it from now on?"
echo >&2
while [ 1 = 1 ]
do
	printf >&2 "yes or no > "
	read x
	
	case "${x}" in
		yes)	cp -f /etc/firehol/RESERVED_IPS /etc/firehol/RESERVED_IPS.old 2>/dev/null
			cat "${tempfile}" >/etc/firehol/RESERVED_IPS || exit 1
			echo >&2 "New RESERVED_IPS written to '/etc/firehol/RESERVED_IPS'."
			break
			;;
			
		no)
			echo >&2 "Saved nothing."
			break
			;;
			
		*)	echo >&2 "Cannot understand '${x}'."
			;;
	esac
done

rm -f ${tempfile}

