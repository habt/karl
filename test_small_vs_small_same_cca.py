
from multiprocessing import Process
import time
import os
import fabfile
from datetime import datetime

def one_large_flow(size="10000000",serv_port="2001",clie_port="300",prot="cubic",bw="15mbit",dl="50ms",small_prot="cubic",small_size="1MB",small_dl="50ms",ite=0,queue_limit=100,waittime=0.0,outfile="name"):
  os.system("ssh habte@192.168.60.198  \"iperf3 -s -D -p  %s \"" %(serv_port))
  starttime=time.time()
  os.system("time sudo iperf3 -c 10.0.1.1 -p %s -n %s --bind 10.0.2.1 --cport %s -C %s >> /mnt/1TB/iperfcaptures/%s_large.txt" %(serv_port,size,clie_port,prot,outfile))
  endtime=time.time()
  os.system("echo 1.0,%s,%s >> /mnt/1TB/iperfcaptures/timestamps/%s.dat &" %(starttime,endtime,outfile))
    
def sstrace(prot="cubic",dur=50.0,limit="1000",dl="50ms"):
    length = int(50.0/0.001)
    print("length is ------------%s"%length)
    for i in range(0,length):
      tm = time.time()
      os.system("echo %s >> captures/%s_%spkts_%srtt_ss.txt" %(tm,prot,limit,dl))
      os.system(" ss -ait | grep -A1 '10.0.1.1' | grep -A1 -E 'ESTAB.*' >> captures/%s_%spkts_%srtt_ss.txt" %(prot,limit,dl))
      time.sleep(0.001)

def succesive_small_flows(rep=10,waittime=0.5,serv_port="2000",clie_port="200",prot="cubic",size="1000000",dl="20ms",bw="15mbit",large_prot="cubic",large_size="1MB",large_dl="50ms",ite=0,queue_limit=100,gap=0.1,outfile="name"):
  os.system("ssh habte@192.168.60.198  \"iperf3 -s -D -p  %s \"" %serv_port)
  time.sleep(waittime)
  for x in range(0, rep):
      starttime=time.time()
      os.system("time sudo iperf3 -c 10.0.1.1 -p {} -n {} --bind 10.0.2.1 --cport {} -C {} >> /mnt/1TB/iperfcaptures/{}_small.txt ".format(serv_port,size,clie_port,prot,outfile))
      endtime=time.time()
      os.system("echo 0.0,%s,%s >> /mnt/1TB/iperfcaptures/timestamps/%s.dat &" %(starttime,endtime,outfile))
      time.sleep(gap)      

#def simaltaneous_small_flows():

def reset_network():
   os.system("fab config_loc_root")
   os.system("fab config_loc_clss")
   os.system("fab config_loc_qdscs")
   os.system("fab config_nw_root")
   os.system("fab config_nw_clss")
   os.system("fab config_nw_qdscs")


def set_network(bw,chbw,burst,ceilbw,lr,limit,dl1,dl2,dl3,dl4):
   os.system("fab change_nw_config:%s,%s,%s,%s,%s,%s,%s,%s,%s,%s >> change.txt" %(bw,chbw,ceilbw,burst,lr,limit,dl1,dl2,dl3,dl4))
   
def vary_network_bw(no_bw,dur,bw,chbw,burst,ceilbw,dl,lr,scale,limit):
  time.sleep(10)
  set_network("2500mbit",chbw,burst,"50mbit",dl,lr,limit)
  time.sleep(10)
  set_network("2500mbit",chbw,burst,"10mbit",dl,lr,limit)
  time.sleep(10)
  set_network("2500mbit",chbw,burst,"50mbit",dl,lr,limit)

#def change_network_buf():

#def change_network_lr():

if __name__ == '__main__':
  
  # always use 200 for bbr client, use 300 for cubic
  prots = ["bbr","cubic","reno"]
  long_rtt_clie_ports = [200,300,300]
  short_rtt_clie_ports = [201, 301,301] 
  long_rtt_serv_ports = [2000,3000,3000]
  short_rtt_serv_ports = [2001,3001,3001]
  dl_long =["45ms","45ms"]#bbrlong,cubiclong
  dl_short=["45ms","45ms"]#bbrshort,cubicshort
  
  large_sizes = ["10000000","30000000"] #10MB,30MB
  small_sizes = ["1000000"] #1MB,1MB
  #small_reps_large1=[160,80,40,20,10,5]
  #small_reps_large2=[320,160,80,40,20,10]
  #small_reps = [10,20]
  
  
  #bws = ["10mbit","20mbit","30mbit","40mbit","50mbit","60mbit","70mbit"] #var BW test operators
  bws=["2.5mbit"] #20, 30,40
  buff_sizes =["5","10","20"] # BDP/2, BDP , 2BDP
  

  exps = ["exp1","exp2"]

  #schemes = ["scheme1","scheme2"]
  waittimes = [0.0,0.5]
  #rep = [10,20]   

  lrs = ["0%"]#,"6%","8%"]

  inter_small_spaces =[0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8] # [0.0, 0.05, 0.1, 0.2, 0.4]
  #space = 0.1;
   
  #test values (not relevant)
  bwlimit = "2500mbit"
  #buff = "500"
  chbw="1bps"
  burst="1600"
  lr="0"
  #bw = bws[1]
  num_ite = 10
  small_size=small_sizes[0] 
  large_size= small_size; # only for two short flow tests
  rep = 10
 
  reset_network()
 
  #set_network(bwlimit,chbw,burst,bw,lr,queue_limit,dl_long[0],dl_short[0],dl_long[1],dl_short[1])#bbrlong,bbrshort,cubiclong,cubicshort
  
  #for bw,buff in zip(bws,buff_sizes):
  for bw in bws: 
    for buff in buff_sizes:
       for lr in lrs:
           set_network(bwlimit,chbw,burst,bw,lr,buff,dl_long[0],dl_short[0],dl_long[1],dl_short[1])#bbrlong,bbrshort,cubiclong,cubicshort
	   for ite in range(0,num_ite): # iterate num_ite times
	      #for large_size,rep in zip(large_sizes,small_reps):
		 for waittime in waittimes:
		   for space in inter_small_spaces:
                    for idx in range(0,3):#index 0 for bbr, 1 for cubic, 2 for reno
		      #for idx2 in range (0,3): # for testing diffrent ccas competing
                      #for small_size,rep in zip(small_sizes,small_reps_large2):  # for different small file size tests
  
  			# CCA related parameters :- Index 0 for BBR and 1 for CUBIC
  			large_prot = prots[idx]
 		        large_serv_port = long_rtt_serv_ports[idx]
 			large_clie_port = long_rtt_clie_ports[idx]
  			if idx > 1:
			   large_dl = dl_long[1] # use dl_short[] to indicate  short rtt flow
			else:
			   large_dl=dl_long[idx]

 			
			idx2=idx   # for testing same  protocols flows			 
  			#idx2=1-idx # for testing different protocols flows
  			small_prot = prots[idx2]
  			small_serv_port = short_rtt_serv_ports[idx2]
  			small_clie_port = short_rtt_clie_ports[idx2]
 			if idx2 > 1:
			   small_dl = dl_short[1]  #use dl_short[] to indicate  short rtt flow
			else:
                           small_dl=dl_short[idx2]

  						


      			print("Now doing: %s , %s , %s , %s , %s , %s , %s , %s , %s , %s"%(bw,buff,lr,ite,large_size,small_size,waittime,space,large_prot,small_prot))
			
			outname= ("%s_%sMB_%s_%s_%sMB_%s_%s_%sbuf_%sperc_%s_%sgap_%s" %(large_prot,large_size,large_dl,small_prot,small_size,small_dl,bw,buff,lr,waittime,space,ite))
  			#p1 = Process(target=one_large_flow,args = (large_size,large_serv_port,large_clie_port,large_prot,bw,large_dl,small_prot,small_size,small_dl,ite,buff,waittime,outname))
  			p2 = Process(target=succesive_small_flows,args=(rep,waittime,small_serv_port,small_clie_port,small_prot,small_size,small_dl,bw,large_size,large_prot,large_dl,ite,buff,space,outname)) 
  			p1 = Process(target=succesive_small_flows,args=(rep,0.0,large_serv_port,large_clie_port,large_prot,small_size,large_dl,bw,large_size,small_prot,small_dl,ite,buff,space,outname))#for two competing short flow test
			os.system("nohup ssh habte@192.168.60.171  \"./qdatacoll.sh %s \" 2>&1 &" %(outname))
			os.system("nohup ./ssTrace.sh %s 2>&1 &"%outname)
  			if ite < 2:
			   os.system("sudo tcpdump -i enp3s0f1 -s 120  -w /mnt/1TB/tcpdumps/%s_client.pcap 2>&1 &" %(outname))
  			p1.start()
  			p2.start()
  			#p3.start()
  			p1.join()
 		 	p2.join()
  			#p3.terminate()
			if ite < 2:
  			   os.system("nohup sudo killall tcpdump 2>&1 &") 
			os.system("nohup kill `pgrep ssTrace.sh` 2>&1 &")
			os.system("nohup ssh habte@192.168.60.171  'kill `pgrep qdatacoll.sh`\' 2>&1 &")
			time.sleep(2)
