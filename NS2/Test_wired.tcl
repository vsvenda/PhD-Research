# Creating New Simulator
set ns [new Simulator]

# Setting up the traces
set f [open Results_wired.tr w]
$ns trace-all $f

$ns use-scheduler Simulink

#Create Nodes
set n(0) [$ns node]
set n(1) [$ns node]
set n(2) [$ns node]
set n(3) [$ns node]
set n(4) [$ns node]
set n(5) [$ns node]

set c 22200

#Configure the exit point
for {set i 0} {$i  < 6} {incr i 1} {
set tap($i) [new Agent/Tap];         # Create a TCPTap Agent
set ipnet($i) [new Network/IP];        # Create a Network agent
$ipnet($i) open writeonly
$tap($i) network $ipnet($i);              # Connect network agent to tap agent
$ns attach-agent $n($i) $tap($i);         # Attach agent to the node.
}

# Configure the Entry point
set k 6
for {set i 0} {$i < 6} {incr i 1} {
set p [expr  $c+$i]
set d [expr  $k+$i]
set tap($d) [new Agent/Tap];         # Create the TCPTap Agent
set bpf($i) [new Network/Pcap/Live];   # Create the bpf
set dev [$bpf($i) open readonly eth0]
$bpf($i) filter "dst port $p"
$tap($d) network $bpf($i);                # Connect bpf to TCPTap Agent
$ns attach-agent $n($i) $tap($d);         # Attach TCPTap Agent to the node
}

createsync 23201
createrecv


#Setup Connections

$ns duplex-link $n(0) $n(1) 0.03Mb 0ms DropTail
$ns duplex-link $n(2) $n(3) 0.03Mb 0ms DropTail
$ns duplex-link $n(4) $n(5) 0.03Mb 0ms DropTail

#Set up Transportation Level Connections

set null_1 [new Agent/Null]
$ns attach-agent $n(1) $null_1

set udp_0 [new Agent/UDP]
$ns attach-agent $n(0) $udp_0

set udp_2 [new Agent/UDP]
$ns attach-agent $n(2) $udp_2

set null_3 [new Agent/Null]
$ns attach-agent $n(3) $null_3

set udp_4 [new Agent/UDP]
$ns attach-agent $n(4) $udp_4

set null_5 [new Agent/Null]
$ns attach-agent $n(5) $null_5

#
#Setup traffic sources
#

set cbr_0 [new Application/Traffic/CBR]
    $cbr_0 set interval_ 0.05
    $cbr_0 set packet_size_ 2000
    $cbr_0 attach-agent $udp_0

set cbr_1 [new Application/Traffic/CBR]
    $cbr_1 set interval_ 0.05
    $cbr_1 set packet_size_ 1000
    $cbr_1 attach-agent $udp_2

set cbr_2 [new Application/Traffic/CBR]
    $cbr_2 set interval_ 0.05
    $cbr_2 set packet_size_ 1000
    $cbr_2 attach-agent $udp_4

# RNG +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#Error Model
#set em [new ErrorModel]
#$em set rate_ 0.003;
#$em unit pkt
#$em ranvar [new RandomVariable/Uniform]
#$em drop-target [new Agent/Null]

#$ns link-lossmodel $em $n(2) $n(3)

#set recvr_delay [new RandomVariable/Uniform];
#$recvr_delay set min_ 1
#$recvr_delay set manx_ 20

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

$ns connect $udp_0 $null_1
   $udp_0 set fid_ 4
$ns connect $udp_2 $null_3
   $udp_2 set fid_ 5
$ns connect $udp_4 $null_5
   $udp_4 set fid_ 6

$ns queue-limit $n(0) $n(1) 5
$ns queue-limit $n(2) $n(3) 5
$ns queue-limit $n(4) $n(5) 5

#Start up the sources
$ns at 0 "$cbr_0 start"
$ns at 0 "$cbr_1 start"
$ns at 0 "$cbr_2 start"

$ns at 30 "$cbr_0 stop"
$ns at 30 "$cbr_1 stop"
$ns at 30 "$cbr_2 stop"

proc finish {} { 
	global ns f
	$ns flush-trace
	close $f
	exit 0
}

$ns at 30.0 "finish"

$ns run