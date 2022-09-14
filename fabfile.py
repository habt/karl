
from fabric.api import run
from fabric.api import env
from fabric.api import local

#env.hosts = ['user@ip']
#env.passwords = {'user@ip': 'password'}

def uname_r():
    run("uname -r")

def change_nw_config(bw="10mbit",chbw="1bps",ceilbw="15mbit",burst="1540",lr="0",limit="300",dl0="20ms",dl1="400ms",dl2="20ms",dl3="20ms"):
    #run("sudo tc qdisc add dev enp6s0f0 root handle 1:0 htb")
    run("sudo tc class change dev ifb0 parent 1: classid 1:1 htb rate %s"%(ceilbw))
    run("sudo tc qdisc change dev ifb0 parent 1:1 handle 10: netem limit %s loss %s"%(limit,lr))

    limit = "3000"
    ceilbw="2000mbit"
    bw="2000mbit"
    lr="0"

    run("sudo ifconfig enp6s0f0 txqueuelen %s"%limit) 
    run("sudo tc class change dev enp6s0f0 parent 1:1 classid 1:1 htb rate %s burst %s" %(bw,burst))
    run("sudo tc class change dev enp6s0f0 parent 1:1 classid 1:10 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class change dev enp6s0f0 parent 1:1 classid 1:11 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class change dev enp6s0f0 parent 1:1 classid 1:20 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class change dev enp6s0f0 parent 1:1 classid 1:21 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class change dev enp6s0f0 parent 1:1 classid 1:30 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
          
    run("sudo tc qdisc change dev enp6s0f0 parent 1:10 handle 110: netem limit %s delay %s loss %s" %(limit,dl0,lr))#bbrlong
    run("sudo tc qdisc change dev enp6s0f0 parent 1:11 handle 111: netem limit %s delay %s loss %s" %(limit,dl1,lr))#bbrshort
    run("sudo tc qdisc change dev enp6s0f0 parent 1:20 handle 220: netem limit %s delay %s loss %s" %(limit,dl2,lr))#cubiclong
    run("sudo tc qdisc change dev enp6s0f0 parent 1:21 handle 221: netem limit %s delay %s loss %s" %(limit,dl3,lr))#cubicshort
    run("sudo tc qdisc change dev enp6s0f0 parent 1:30 handle 330: netem limit %s delay %s loss %s" %(limit,dl0,lr))

        
def config_nw_root(bw="10mbit",burst="1540"):
    run("sudo tc qdisc del dev enp6s0f0 root")
    run("sudo tc qdisc add dev enp6s0f0 root handle 1:0 htb")
    run("sudo tc class add dev enp6s0f0 parent 1:1 classid 1:1 htb rate %s burst %s" %(bw,burst))
    
    run("sudo tc qdisc del dev ifb0 root")    
    run("sudo tc qdisc add dev ifb0 root handle 1: htb default 1")
    run("sudo tc class add dev ifb0 parent 1: classid 1:1 htb rate %s"%(bw))
    
def config_nw_clss(chbw="1bps",ceilbw="20mbit",burst="1540"):
    run("sudo tc class add dev enp6s0f0 parent 1:1 classid 1:10 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class add dev enp6s0f0 parent 1:1 classid 1:11 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class add dev enp6s0f0 parent 1:1 classid 1:20 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class add dev enp6s0f0 parent 1:1 classid 1:21 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))
    run("sudo tc class add dev enp6s0f0 parent 1:1 classid 1:30 htb rate %s ceil %s burst %s" %(chbw,ceilbw,burst))

    run("sudo tc filter add dev enp6s0f0 protocol ip parent 1: prio 1 u32 match ip sport 200 0xffff flowid 1:10")
    run("sudo tc filter add dev enp6s0f0 protocol ip parent 1: prio 1 u32 match ip sport 201 0xffff flowid 1:11")
    run("sudo tc filter add dev enp6s0f0 protocol ip parent 1: prio 1 u32 match ip sport 300 0xffff flowid 1:20")
    run("sudo tc filter add dev enp6s0f0 protocol ip parent 1: prio 1 u32 match ip sport 301 0xffff flowid 1:21")
    run("sudo tc filter add dev enp6s0f0 protocol ip parent 1: prio 2 u32 match ip protocol 1 0xff flowid 1:30")

def config_nw_qdscs(dl="50ms",lr="0",limit="1000"):
    run("sudo tc qdisc add dev enp6s0f0 parent 1:10 handle 110: netem limit %s delay %s loss %s" %(limit,dl,lr))
    run("sudo tc qdisc add dev enp6s0f0 parent 1:11 handle 111: netem limit %s delay %s loss %s" %(limit,dl,lr))
    run("sudo tc qdisc add dev enp6s0f0 parent 1:20 handle 220: netem limit %s delay %s loss %s" %(limit,dl,lr))
    run("sudo tc qdisc add dev enp6s0f0 parent 1:21 handle 221: netem limit %s delay %s loss %s" %(limit,dl,lr))
    run("sudo tc qdisc add dev enp6s0f0 parent 1:30 handle 330: netem limit %s delay %s loss %s" %(limit,dl,lr))

    run("sudo tc qdisc add dev ifb0 parent 1:1 handle 10: netem limit %s loss %s"%(limit,lr))

def config_loc_root(bw="1000000mbit",burst="1540"):
    local("sudo tc qdisc del dev enp3s0f1 root")
    local("sudo tc qdisc add dev enp3s0f1 root handle 1:0 htb")
    local("sudo tc class add dev enp3s0f1 parent 1:1 classid 1:1 htb rate %s burst %s" %(bw,burst))

def config_loc_clss(bw="1bps",ceilbw="5000000mbit",burst="1540"): 
    local("sudo tc class add dev enp3s0f1 parent 1:1 classid 1:10 htb rate %s ceil %s burst %s" %(bw,ceilbw,burst))
    local("sudo tc class add dev enp3s0f1 parent 1:1 classid 1:11 htb rate %s ceil %s burst %s" %(bw,ceilbw,burst))
    local("sudo tc class add dev enp3s0f1 parent 1:1 classid 1:20 htb rate %s ceil %s burst %s" %(bw,ceilbw,burst))
    local("sudo tc class add dev enp3s0f1 parent 1:1 classid 1:21 htb rate %s ceil %s burst %s" %(bw,ceilbw,burst))

    local("sudo tc filter add dev enp3s0f1 protocol ip parent 1: prio 1 u32 match ip sport 200 0xffff flowid 1:10")
    local("sudo tc filter add dev enp3s0f1 protocol ip parent 1: prio 1 u32 match ip sport 201 0xffff flowid 1:11")
    local("sudo tc filter add dev enp3s0f1 protocol ip parent 1: prio 1 u32 match ip sport 300 0xffff flowid 1:20")
    local("sudo tc filter add dev enp3s0f1 protocol ip parent 1: prio 1 u32 match ip sport 301 0xffff flowid 1:21")

def config_loc_qdscs():
    local("sudo tc qdisc add dev enp3s0f1 parent 1:10 handle 110: fq pacing")
    local("sudo tc qdisc add dev enp3s0f1 parent 1:11 handle 111: fq pacing")
    local("sudo tc qdisc add dev enp3s0f1 parent 1:20 handle 220: pfifo_fast")
    local("sudo tc qdisc add dev enp3s0f1 parent 1:21 handle 221: pfifo_fast")
