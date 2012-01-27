#!/bin/bash

#
# Phil Whineray 2011/03/06
#   Updated to work with latest iana file format, remove a couple of bash-isms
#   and use the file RESERVED_IPV4 so that we can be used with the IPv6 capable
#   firehol.
#
# $Id$
#
# $Log$
# Revision 1.14  2010/06/07 15:44:09  ktsaou
# Made get-iana.sh support the latest IANA format.
#
# Revision 1.13  2010/04/08 22:03:08  ktsaou
# Removed --proxy=off for wget.
#
# Revision 1.12  2008/03/17 22:08:43  ktsaou
# Updated for latest IANA reservations format.
#
# Revision 1.11  2007/06/13 14:40:04  ktsaou
# *** empty log message ***
#
# Revision 1.10  2007/05/05 23:38:31  ktsaou
# Added support for external definitions of:
#
# RESERVED_IPS
# PRIVATE_IPS
# MULTICAST_IPS
# UNROUTABLE_IPS
#
# in files under the same name in /etc/firehol/.
# Only RESERVED_IPS is mandatory (firehol will complain if it is not there,
# but it will still work without it), and is also the only file that firehol
# checks how old is it. If it is 90+ days old, firehol will complain again.
#
# Changed the supplied get-iana.sh script to generate the RESERVED_IPS file.
# FireHOL also instructs the user to use this script if the file is missing
# or is too old.
#
# Revision 1.9  2007/04/29 19:34:11  ktsaou
# *** empty log message ***
#
# Revision 1.8  2005/06/02 15:48:52  ktsaou
# Allowed 127.0.0.1 to be in RESERVED_IPS
#
# Revision 1.7  2005/05/08 23:27:23  ktsaou
# Updated RESERVED_IPS to current IANA reservations.
#
# Revision 1.6  2004/01/10 18:44:39  ktsaou
# Further optimized and reduced PRIVATE_IPS using:
# http://www.vergenet.net/linux/aggregate/
#
# The supplied get-iana.sh uses 'aggregate-flim' if it finds it in the path.
# (aggregate-flim is the name of this program when installed on Gentoo)
#
# Revision 1.5  2003/08/23 23:26:50  ktsaou
# Bug #793889:
# Change #!/bin/sh to #!/bin/bash to allow FireHOL run on systems that
# bash is not linked to /bin/sh.
#
# Revision 1.4  2002/10/27 12:44:42  ktsaou
# CVS test
#

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
# (i.e. not include them in RESERVED_IPV4)?
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
printf "RESERVED_IPV4=\""
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
echo >&2 "/etc/firehol/RESERVED_IPV4:"

echo >&2 "# diff /etc/firehol/RESERVED_IPV4 ${tempfile}"
diff /etc/firehol/RESERVED_IPV4 ${tempfile}

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
echo >&2 "Would you like to save this list to /etc/firehol/RESERVED_IPV4"
echo >&2 "so that FireHOL will automatically use it from now on?"
echo >&2
while [ 1 = 1 ]
do
	printf >&2 "yes or no > "
	read x
	
	case "${x}" in
		yes)	cp -f /etc/firehol/RESERVED_IPV4 /etc/firehol/RESERVED_IPV4.old 2>/dev/null
			cat "${tempfile}" >/etc/firehol/RESERVED_IPV4 || exit 1
			echo >&2 "New RESERVED_IPV4 written to '/etc/firehol/RESERVED_IPV4'."
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

