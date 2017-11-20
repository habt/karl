#!/bin/bash

#dir=./ssout/45ms_sameprot
dir=$1
mkdir $dir/parsed
out_dir=$dir/parsed/
file_match=$dir/*

srcaddr='10.0.2.1'
dstaddr='10.0.1.1'

declare -a srcprt=('200' '201' '300' '301');
declare -a dstprt=('2000' '2001' '3000' '3001');
declare -a cca_pos_regexs=('"bbr_"*' '*"_bbr_"*' '"cubic_"*' '*"_cubic_"*' '"reno_"*' ' *"_reno_"*');
declare -a first_greps=('10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' '10.0.2.1:300 10.0.1.1:3000 cubic.*' '10.0.2.1:301 10.0.1.1:3001 cubic.*' '10.0.2.1:300 10.0.1.1:3000 reno.*' '10.0.2.1:301 10.0.1.1:3001 reno.*');

srate_end=_send.txt
prate_end=_prate.txt
cwnd_end=_cwnd.txt

tstamp_end=_tstamp.txt
rtt_end=_rtt.txt
acked_end=_backed.txt

lar=_large
sma=_small

for fn in $file_match
do
  #filename=`echo $fn | sed 's/.\/ssout\/45ms_sameprot\///g' | sed 's/.txt//g'`
  filename=`echo $fn | sed 's/.*\///g' | sed 's/.txt//g'`

  #grep -oP '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*ESTAB' $fn | grep -oP "(?<=send )[^Mbps ]+" >> $out_dir$filename
  #grep -B 1 '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*ESTAB'$fn # to extract with the previous line with timestamp 
  #grep -B 1 '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn  | sed 's/ESTAB.*//' >> $out_dir$filename$tstamp  # to extract just the time stamps

  #grep -B 1 '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' bbr_30000000MB_45ms_bbr_1000000MB_45ms_6mbit_400buf_0perc_0.0_1_1495813469.67_ss.txt | grep ^"ESTAB.*" >> $out_dir$filename$tstamp
  
  #BBR
  if [[ $filename == "bbr_"* ]]; then # large BBR flow parse
	lar=_bbrone
	grep -oP '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=cwnd:)[^ ssthresh ]+" >> $out_dir$filename$lar$cwnd_end   # extract CWND
        grep -oP '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=send )[^(Mbps)(K) ]+" >> $out_dir$filename$lar$srate_end #extract send rate
        grep -oP '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=pacing_rate )[^(Mbps)(K) ]+" >> $out_dir$filename$lar$prate_end   # extract pacing rate
        grep -oP '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=rtt:)[^/ ]+" >> $out_dir$filename$lar$rtt_end   # extract RTT
	grep -oP '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=bytes_acked:)[^ segs_out ]+" >> $out_dir$filename$lar$acked_end   # extract acked bytes
	grep -B 1 '10.0.2.1:200 10.0.1.1:cisco-sccp bbr.*' $fn  | grep -v "ESTAB.*" >> $out_dir$filename$lar$tstamp_end  # to extract just the time stamps
  fi
  if [[ $filename == *"_bbr_"* ]]; then # small BBR flow parse
	sma=_bbrtwo
  	grep -oP '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=send )[^(Mbps)(K) ]+" >> $out_dir$filename$sma$srate_end  #extract send rate
  	grep -oP '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=cwnd:)[^ ssthresh ]+" >> $out_dir$filename$sma$cwnd_end   # extract CWND
 	grep -oP '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=pacing_rate )[^(Mbps)(K) ]+" >> $out_dir$filename$sma$prate_end  #extract pacing rate
	grep -oP '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=rtt:)[^/ ]+" >> $out_dir$filename$sma$rtt_end   # extract RTT
	grep -oP '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=bytes_acked:)[^ segs_out ]+" >> $out_dir$filename$sma$acked_end  #extract acked bytes 
	grep -B 1 '10.0.2.1:at-rtmp 10.0.1.1:2001 bbr.*' $fn | grep -v "ESTAB.*" | grep -v '[^0-9\.]' >> $out_dir$filename$sma$tstamp_end
  fi  
  

  #CUBIC
  if [[ $filename == "cubic_"* ]]; then # large Cubic flow parse
	lar=_cubicone
  	grep -oP '10.0.2.1:300 10.0.1.1:3000 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=cwnd:)[^ ssthresh ]+" >> $out_dir$filename$lar$cwnd_end # extract CWND
  	grep -oP '10.0.2.1:300 10.0.1.1:3000 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=send )[^(Mbps)(K) ]+" >> $out_dir$filename$lar$srate_end   # extract send rate
	grep -oP '10.0.2.1:300 10.0.1.1:3000 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=pacing_rate )[^(Mbps)(K) ]+" >> $out_dir$filename$lar$prate_end   # extract pacing rate
	grep -oP '10.0.2.1:300 10.0.1.1:3000 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=rtt:)[^/ ]+" >> $out_dir$filename$lar$rtt_end   # extract RTT
	grep -oP '10.0.2.1:300 10.0.1.1:3000 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=bytes_acked:)[^ segs_out ]+" >> $out_dir$filename$lar$acked_end   # extract acked bytes
  	grep -B 1 '10.0.2.1:300 10.0.1.1:3000 cubic.*' $fn | grep -v "ESTAB.*" >> $out_dir$filename$lar$tstamp_end  # to extract just the time stamps
  fi
  if [[ $filename == *"_cubic_"* ]]; then # small Cubic flow parse
	sma=_cubictwo
        grep -oP '10.0.2.1:301 10.0.1.1:3001 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=cwnd:)[^ ssthresh ]+" >> $out_dir$filename$sma$cwnd_end # extract CWND
        grep -oP '10.0.2.1:301 10.0.1.1:3001 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=send )[^(Mbps)(K) ]+" >> $out_dir$filename$sma$srate_end # extract send rate
  	grep -oP '10.0.2.1:301 10.0.1.1:3001 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=pacing_rate )[^(Mbps)(K) ]+" >> $out_dir$filename$sma$prate_end  #extract pacing rate
	grep -oP '10.0.2.1:301 10.0.1.1:3001 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=rtt:)[^/ ]+" >> $out_dir$filename$sma$rtt_end   # extract RTT
	grep -oP '10.0.2.1:301 10.0.1.1:3001 cubic.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=bytes_acked:)[^ segs_out ]+" >> $out_dir$filename$sma$acked_end  #extract acked bytes 
	grep -B 1 '10.0.2.1:301 10.0.1.1:3001 cubic.*' $fn | grep -v "ESTAB.*" | grep -v '[^0-9\.]' >> $out_dir$filename$sma$tstamp_end
  fi


  #reno
  if [[ $filename == "reno_"* ]]; then # large Reno flow parse
	lar=_renoone
        grep -oP '10.0.2.1:300 10.0.1.1:3000 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=cwnd:)[^ ssthresh ]+" >> $out_dir$filename$lar$cwnd_end # extract CWND
        grep -oP '10.0.2.1:300 10.0.1.1:3000 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=send )[^(Mbps)(K) ]+" >> $out_dir$filename$lar$srate_end   # extract send rate
  	grep -oP '10.0.2.1:300 10.0.1.1:3000 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=pacing_rate )[^(Mbps)(K) ]+" >> $out_dir$filename$lar$prate_end   # extract pacing rate
	grep -oP '10.0.2.1:300 10.0.1.1:3000 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=rtt:)[^/ ]+" >> $out_dir$filename$lar$rtt_end   # extract RTT
	grep -oP '10.0.2.1:300 10.0.1.1:3000 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=bytes_acked:)[^ segs_out ]+" >> $out_dir$filename$lar$acked_end   # extract acked bytes
	grep -B 1 '10.0.2.1:300 10.0.1.1:3000 reno.*' $fn | grep -v "ESTAB.*" >> $out_dir$filename$lar$tstamp_end  # to extract just the time stamps
  fi
  if [[ $filename == *"_reno_"* ]]; then # small Reno flow parse
	sma=_renotwo
        grep -oP '10.0.2.1:301 10.0.1.1:3001 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=cwnd:)[^ ssthresh ]+" >> $out_dir$filename$sma$cwnd_end # extract CWND
        grep -oP '10.0.2.1:301 10.0.1.1:3001 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=send )[^(Mbps)(K) ]+" >> $out_dir$filename$sma$srate_end # extract send rate
	grep -oP '10.0.2.1:301 10.0.1.1:3001 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=pacing_rate )[^(Mbps)(K) ]+" >> $out_dir$filename$sma$prate_end  #extract pacing rate
	grep -oP '10.0.2.1:301 10.0.1.1:3001 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=rtt:)[^/ ]+" >> $out_dir$filename$sma$rtt_end   # extract RTT
	grep -oP '10.0.2.1:301 10.0.1.1:3001 reno.*' $fn | sed 's/ESTAB.*//' | grep -oP "(?<=bytes_acked:)[^ segs_out ]+" >> $out_dir$filename$sma$acked_end  #extract acked bytes 
  	grep -B 1 '10.0.2.1:301 10.0.1.1:3001 reno.*' $fn | grep -v "ESTAB.*"  | grep -v '[^0-9\.]' >> $out_dir$filename$sma$tstamp_end
  fi

  #echo "${cca_pos_regexs[0]}"
  #echo $fn
  echo $filename
done


