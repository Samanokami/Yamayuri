#!/bin/sh
files=(`ls ./txt`)
for arg in ${files[@]}
do
	gawk -f touko.awk ./txt/${arg}
done
#cygstart http://www.ieee.org/ucm/groups/public/@ieee/@web/@org/@about/documents/images/30020140.jpg
