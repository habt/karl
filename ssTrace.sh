#!/bin/sh
#i=0
#base=1
while true 
do 
	echo `date +%s%3N` >>/mnt/1TB/ssout/"$1"_ss.txt 
	ssOut=`ss -ait | grep -A1 '10.0.1.1' | grep -A1 -E 'ESTAB.*'`
	echo $ssOut >> /mnt/1TB/ssout/"$1"_ss.txt
	sleep 0.001
	clear 
	#i=$((i+base))
done
