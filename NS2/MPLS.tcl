# Creating New Simulator
set ns [new Simulator]

# Setting up the traces
set f [open Results_MPLS.tr w]
$ns trace-all $f

set nf [open Results_MPLS.nam w]
$ns namtrace-all $nf

$ns use-scheduler Simulink

#Create topology instance
set topo	[new Topography]
$topo load_flatgrid 1000 1000

$ns node-config topoInstance $topo

#Create Nodes
set n(0) [$ns node]
set n(1) [$ns node]
#$ns node-config -MPLS ON
set n(2) [$ns mpls-node]
#$ns node-config -MPLS OFF


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
$ns duplex-link $n(0) $n(2) 0.03Mb 0ms DropTail
$ns duplex-link $n(5) $n(2) 0.03Mb 0ms DropTail
$ns duplex-link $n(2) $n(1) 0.05Mb 0ms DropTail

$ns duplex-link $n(3) $n(4) 0.03Mb 0ms DropTail


#Set up Transportation Level Connections
set null_1 [new Agent/Null]
$ns attach-agent $n(1) $null_1

set udp_0 [new Agent/UDP]
$ns attach-agent $n(0) $udp_0

set udp_5 [new Agent/UDP]
$ns attach-agent $n(5) $udp_5

set null_4 [new Agent/Null]
$ns attach-agent $n(4) $null_4

set udp_3 [new Agent/UDP]
$ns attach-agent $n(3) $udp_3

####$ns configure-ldp-on-all-mpls-nodes
#Setting up MPLS
set a n(2)
set m [eval $$a get-module "MPLS"]
$m enable-reroute "new"

[$n(2) get-module "MPLS"] enable-data-driven

#Setup traffic sources
set cbr_0 [new Application/Traffic/CBR]
    $cbr_0 set interval_ 0.05
    $cbr_0 set packet_size_ 200
    $cbr_0 attach-agent $udp_0

set cbr_1 [new Application/Traffic/CBR]
    $cbr_1 set interval_ 0.05
    $cbr_1 set packet_size_ 200
    $cbr_1 attach-agent $udp_3

set cbr_2 [new Application/Traffic/CBR]
    $cbr_2 set interval_ 0.05
    $cbr_2 set packet_size_ 200
    $cbr_2 attach-agent $udp_5

$ns connect $udp_0 $null_1
   $udp_0 set fid_ 4

$ns connect $udp_3 $null_4
   $udp_3 set fid_ 5

$ns connect $udp_5 $null_1
   $udp_5 set fid_ 6

$ns queue-limit $n(0) $n(2) 5
$ns queue-limit $n(5) $n(2) 5
$ns queue-limit $n(2) $n(1) 50
$ns queue-limit $n(3) $n(4) 5

#Start up the sources
$ns at 0 "$cbr_0 start"
$ns at 0 "$cbr_1 start"
$ns at 0 "$cbr_2 start"

$ns at 10 "$cbr_0 stop"
$ns at 10 "$cbr_1 stop"
$ns at 10 "$cbr_2 stop"

proc finish {} { 
	global ns f
	$ns flush-trace
	close $f
	exit 0
}

$ns at 10.0 "finish"

$ns run