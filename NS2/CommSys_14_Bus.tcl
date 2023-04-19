# ******** Creating new simulator ********
set ns [new Simulator]

# ******** Setting up the traces ********
set f [open Results_14_Bus.tr w]
$ns trace-all $f

$ns use-scheduler Simulink

# ******** Create nodes ********
# --- RTU ---
set n(0) [$ns node]
set n(1) [$ns node]
set n(2) [$ns node]
set n(3) [$ns node]
set n(4) [$ns node]
set n(5) [$ns node]
set n(6) [$ns node]
set n(7) [$ns node]
set n(8) [$ns mpls-node]
set n(9) [$ns node]

# --- PMU ---
set n(10) [$ns node]
set n(11) [$ns node]
set n(12) [$ns node]
set n(13) [$ns node]
set n(14) [$ns node]
set n(15) [$ns node]

set c 22200

# ******** Configure the exit point ********
for {set i 0} {$i  < 16} {incr i 1} {
set tap($i) [new Agent/Tap];         # Create a TCPTap Agent
set ipnet($i) [new Network/IP];        # Create a Network agent
$ipnet($i) open writeonly
$tap($i) network $ipnet($i);              # Connect network agent to tap agent
$ns attach-agent $n($i) $tap($i);         # Attach agent to the node.
}

# ******** Configure the entry point ********
set k 16
for {set i 0} {$i < 16} {incr i 1} {
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

# ******** Setup connections ********
# --- RTU ---
set delay_RTU [new RandomVariable/Normal]
$delay_RTU set avg_ 400
$delay_RTU set std_ 50

$ns duplex-link $n(0) $n(8) 0.01Mb 100ms DropTail
$ns duplex-link $n(1) $n(8) 0.02Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(2) $n(8) 0.03Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(3) $n(8) 0.04Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(4) $n(8) 0.05Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(5) $n(8) 2Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(6) $n(8) 2Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(7) $n(8) 2Mb [$delay_RTU value]ms DropTail
$ns duplex-link $n(8) $n(9) 1Mb 100ms DropTail

# --- PMU ---
set delay_PMU [new RandomVariable/Normal]
$delay_PMU set avg_ 400
$delay_PMU set std_ 5

$ns duplex-link $n(10) $n(9) 0.02Mb [$delay_PMU value]ms DropTail
$ns duplex-link $n(11) $n(9) 0.02Mb [$delay_PMU value]ms DropTail
$ns duplex-link $n(12) $n(9) 0.02Mb [$delay_PMU value]ms DropTail
$ns duplex-link $n(13) $n(9) 0.02Mb [$delay_PMU value]ms DropTail
$ns duplex-link $n(14) $n(9) 0.02Mb [$delay_PMU value]ms DropTail
$ns duplex-link $n(15) $n(9) 0.02Mb [$delay_PMU value]ms DropTail

# ******** Set up transportation level connections ********
# --- RTU ---
set null_n(9) [new Agent/Null]
    $ns attach-agent $n(9) $null_n(9)
set udp_n(0) [new Agent/UDP]
    $ns attach-agent $n(0) $udp_n(0)
set udp_n(1) [new Agent/UDP]
    $ns attach-agent $n(1) $udp_n(1)
set udp_n(2) [new Agent/UDP]
    $ns attach-agent $n(2) $udp_n(2)
set udp_n(3) [new Agent/UDP]
    $ns attach-agent $n(3) $udp_n(3)
set udp_n(4) [new Agent/UDP]
    $ns attach-agent $n(4) $udp_n(4)
set udp_n(5) [new Agent/UDP]
    $ns attach-agent $n(5) $udp_n(5)
set udp_n(6) [new Agent/UDP]
    $ns attach-agent $n(6) $udp_n(6)
set udp_n(7) [new Agent/UDP]
    $ns attach-agent $n(7) $udp_n(7)

# Setting up MPLS
set a n(8)
set m [eval $$a get-module "MPLS"]
$m enable-reroute "new"
[$n(8) get-module "MPLS"] enable-data-driven

# --- PMU ---
set udp_n(10) [new Agent/UDP]
    $ns attach-agent $n(10) $udp_n(10)
set udp_n(11) [new Agent/UDP]
    $ns attach-agent $n(11) $udp_n(11)
set udp_n(12) [new Agent/UDP]
    $ns attach-agent $n(12) $udp_n(12)
set udp_n(13) [new Agent/UDP]
    $ns attach-agent $n(13) $udp_n(13)
set udp_n(14) [new Agent/UDP]
    $ns attach-agent $n(14) $udp_n(14)
set udp_n(15) [new Agent/UDP]
    $ns attach-agent $n(15) $udp_n(15)

# ******** Setup traffic ********
# --- RTU ---
set cbr_n(0) [new Application/Traffic/CBR]
    $cbr_n(0) set interval_ 0.2
    $cbr_n(0) set packet_size_ 1000
    $cbr_n(0) attach-agent $udp_n(0)
set cbr_n(1) [new Application/Traffic/CBR]
    $cbr_n(1) set interval_ 0.2
    $cbr_n(1) set packet_size_ 1000
    $cbr_n(1) attach-agent $udp_n(1)
set cbr_n(2) [new Application/Traffic/CBR]
    $cbr_n(2) set interval_ 0.2
    $cbr_n(2) set packet_size_ 1000
    $cbr_n(2) attach-agent $udp_n(2)
set cbr_n(3) [new Application/Traffic/CBR]
    $cbr_n(3) set interval_ 0.2
    $cbr_n(3) set packet_size_ 1000
    $cbr_n(3) attach-agent $udp_n(3)
set cbr_n(4) [new Application/Traffic/CBR]
    $cbr_n(4) set interval_ 0.2
    $cbr_n(4) set packet_size_ 1000
    $cbr_n(4) attach-agent $udp_n(4)
set cbr_n(5) [new Application/Traffic/CBR]
    $cbr_n(5) set interval_ 0.2
    $cbr_n(5) set packet_size_ 1000
    $cbr_n(5) attach-agent $udp_n(5)
set cbr_n(6) [new Application/Traffic/CBR]
    $cbr_n(6) set interval_ 0.2
    $cbr_n(6) set packet_size_ 1000
    $cbr_n(6) attach-agent $udp_n(6)
set cbr_n(7) [new Application/Traffic/CBR]
    $cbr_n(7) set interval_ 0.2
    $cbr_n(7) set packet_size_ 1000
    $cbr_n(7) attach-agent $udp_n(7)

$ns connect $udp_n(0) $null_n(9)
   $udp_n(0) set fid_ 4
$ns connect $udp_n(1) $null_n(9)
   $udp_n(1) set fid_ 5
$ns connect $udp_n(2) $null_n(9)
   $udp_n(2) set fid_ 6
$ns connect $udp_n(3) $null_n(9)
   $udp_n(3) set fid_ 7
$ns connect $udp_n(4) $null_n(9)
   $udp_n(4) set fid_ 8
$ns connect $udp_n(5) $null_n(9)
   $udp_n(5) set fid_ 9
$ns connect $udp_n(6) $null_n(9)
   $udp_n(6) set fid_ 10
$ns connect $udp_n(7) $null_n(9)
   $udp_n(7) set fid_ 11

$ns queue-limit $n(0) $n(8) 2
$ns queue-limit $n(1) $n(8) 2
$ns queue-limit $n(2) $n(8) 2
$ns queue-limit $n(3) $n(8) 2
$ns queue-limit $n(4) $n(8) 2
$ns queue-limit $n(5) $n(8) 2
$ns queue-limit $n(6) $n(8) 2
$ns queue-limit $n(7) $n(8) 2
$ns queue-limit $n(8) $n(9) 20

# --- PMU ---
set cbr_n(10) [new Application/Traffic/CBR]
    $cbr_n(10) set interval_ 2
    $cbr_n(10) set packet_size_ 1000
    $cbr_n(10) attach-agent $udp_n(10)
set cbr_n(11) [new Application/Traffic/CBR]
    $cbr_n(11) set interval_ 2
    $cbr_n(11) set packet_size_ 1000
    $cbr_n(11) attach-agent $udp_n(11)
set cbr_n(12) [new Application/Traffic/CBR]
    $cbr_n(12) set interval_ 2
    $cbr_n(12) set packet_size_ 1000
    $cbr_n(12) attach-agent $udp_n(12)
set cbr_n(13) [new Application/Traffic/CBR]
    $cbr_n(13) set interval_ 2
    $cbr_n(13) set packet_size_ 1000
    $cbr_n(13) attach-agent $udp_n(13)
set cbr_n(14) [new Application/Traffic/CBR]
    $cbr_n(14) set interval_ 2
    $cbr_n(14) set packet_size_ 1000
    $cbr_n(14) attach-agent $udp_n(14)
set cbr_n(15) [new Application/Traffic/CBR]
    $cbr_n(15) set interval_ 2
    $cbr_n(15) set packet_size_ 1000
    $cbr_n(15) attach-agent $udp_n(15)

$ns connect $udp_n(10) $null_n(9)
   $udp_n(10) set fid_ 12
$ns connect $udp_n(11) $null_n(9)
   $udp_n(11) set fid_ 13
$ns connect $udp_n(12) $null_n(9)
   $udp_n(12) set fid_ 14
$ns connect $udp_n(13) $null_n(9)
   $udp_n(13) set fid_ 15
$ns connect $udp_n(14) $null_n(9)
   $udp_n(14) set fid_ 16
$ns connect $udp_n(15) $null_n(9)
   $udp_n(15) set fid_ 17

$ns queue-limit $n(10) $n(9) 5
$ns queue-limit $n(11) $n(9) 5
$ns queue-limit $n(12) $n(9) 5
$ns queue-limit $n(13) $n(9) 5
$ns queue-limit $n(14) $n(9) 5
$ns queue-limit $n(15) $n(9) 5

# ******** Transmission drop model ********
# --- RTU ---
set em_RTU1 [new ErrorModel]
$em_RTU1 set rate_ 0.02;
$em_RTU1 unit pkt
$em_RTU1 ranvar [new RandomVariable/Uniform]
$em_RTU1 drop-target [new Agent/Null]

$ns link-lossmodel $em_RTU1 $n(0) $n(8)
$ns link-lossmodel $em_RTU1 $n(1) $n(8)

set em_RTU2 [new ErrorModel]
$em_RTU2 set rate_ 0.02;
$em_RTU2 unit pkt
$em_RTU2 ranvar [new RandomVariable/Uniform]
$em_RTU2 drop-target [new Agent/Null]

$ns link-lossmodel $em_RTU2 $n(2) $n(8)
$ns link-lossmodel $em_RTU2 $n(3) $n(8)

set em_RTU3 [new ErrorModel]
$em_RTU3 set rate_ 0.02;
$em_RTU3 unit pkt
$em_RTU3 ranvar [new RandomVariable/Uniform]
$em_RTU3 drop-target [new Agent/Null]

$ns link-lossmodel $em_RTU3 $n(4) $n(8)
$ns link-lossmodel $em_RTU3 $n(5) $n(8)

set em_RTU4 [new ErrorModel]
$em_RTU4 set rate_ 0.02;
$em_RTU4 unit pkt
$em_RTU4 ranvar [new RandomVariable/Uniform]
$em_RTU4 drop-target [new Agent/Null]

$ns link-lossmodel $em_RTU4 $n(6) $n(8)
$ns link-lossmodel $em_RTU4 $n(7) $n(8)

set em_SCADA [new ErrorModel]
$em_SCADA set rate_ 0.01;
$em_SCADA unit pkt
$em_SCADA ranvar [new RandomVariable/Uniform]
$em_SCADA drop-target [new Agent/Null]

$ns link-lossmodel $em_SCADA $n(8) $n(9)

# --- PMU ---
set em_PMU1 [new ErrorModel]
$em_PMU1 set rate_ 0.04;
$em_PMU1 unit pkt
$em_PMU1 ranvar [new RandomVariable/Uniform]
$em_PMU1 drop-target [new Agent/Null]

$ns link-lossmodel $em_PMU1 $n(10) $n(9)
$ns link-lossmodel $em_PMU1 $n(11) $n(9)

set em_PMU2 [new ErrorModel]
$em_PMU2 set rate_ 0.04;
$em_PMU2 unit pkt
$em_PMU2 ranvar [new RandomVariable/Uniform]
$em_PMU2 drop-target [new Agent/Null]

$ns link-lossmodel $em_PMU2 $n(12) $n(9)
$ns link-lossmodel $em_PMU2 $n(13) $n(9)

set em_PMU3 [new ErrorModel]
$em_PMU3 set rate_ 0.04;
$em_PMU3 unit pkt
$em_PMU3 ranvar [new RandomVariable/Uniform]
$em_PMU3 drop-target [new Agent/Null]

#$ns link-lossmodel $em_PMU3 $n(14) $n(9)
#$ns link-lossmodel $em_PMU3 $n(15) $n(9)

# multi-state error model *************************************************
#set tmp [new ErrorModel/Uniform 0 pkt]
#set tmp1 [new ErrorModel/Uniform 1 pkt]
#set tmp2 [new ErrorModel/Uniform 0 pkt]

#set m_states [list $tmp $tmp1 $tmp2]

#set m_periods [list 500 1000 500]

#set m_transmx { {0.95 0.05 0}
#    {0 0 1}
#    {1 0 0} }
#set m_trunit pkt

#set m_sttype time
#set m_nstates 3
#set m_nstart [lindex $m_states 0]

#set em_multistate [new ErrorModel/MultiState $m_states $m_periods $m_transmx $m_trunit $m_sttype $m_nstates $m_nstart]
#$ns link-lossmodel $em_multistate $n(15) $n(9)
# *************************************************************************

# ******** Start up the sources ********
# --- RTU ---
$ns at 0 "$cbr_n(0) start"
$ns at 0 "$cbr_n(1) start"
$ns at 0 "$cbr_n(2) start"
$ns at 0 "$cbr_n(3) start"
$ns at 0 "$cbr_n(4) start"
$ns at 0 "$cbr_n(5) start"
$ns at 0 "$cbr_n(6) start"
$ns at 0 "$cbr_n(7) start"

$ns at 2000 "$cbr_n(0) stop"
$ns at 2000 "$cbr_n(1) stop"
$ns at 2000 "$cbr_n(2) stop"
$ns at 2000 "$cbr_n(3) stop"
$ns at 2000 "$cbr_n(4) stop"
$ns at 2000 "$cbr_n(5) stop"
$ns at 2000 "$cbr_n(6) stop"
$ns at 2000 "$cbr_n(7) stop"

# --- PMU ---
$ns at 0 "$cbr_n(10) start"
$ns at 0 "$cbr_n(11) start"
$ns at 0 "$cbr_n(12) start"
$ns at 0 "$cbr_n(13) start"
$ns at 0 "$cbr_n(14) start"
$ns at 0 "$cbr_n(15) start"

$ns at 2000 "$cbr_n(10) stop"
$ns at 2000 "$cbr_n(11) stop"
$ns at 2000 "$cbr_n(12) stop"
$ns at 2000 "$cbr_n(13) stop"
$ns at 2000 "$cbr_n(14) stop"
$ns at 2000 "$cbr_n(15) stop"

proc finish {} { 
	global ns f
	$ns flush-trace
	close $f
	exit 0
}

$ns at 2100.0 "finish"

$ns run