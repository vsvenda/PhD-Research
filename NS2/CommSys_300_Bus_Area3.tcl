# ******** Creating new simulator ********
set ns [new Simulator]

# ******** Setting up the traces ********
set f [open Results_300_Bus_Area3.tr w]
$ns trace-all $f

$ns use-scheduler Simulink

# ******** Create nodes ********
# --- RTU ---
for {set i 0} {$i < 63} {incr i 1} {
set n($i) [$ns node]
}

# --- SCADA ---
for {set i 63} {$i < 66} {incr i 1} {
set n($i) [$ns mpls-node]
}

# --- EMS ---
set n(66) [$ns node]

set c 22200

# ******** Configure the exit point ********
for {set i 0} {$i  < 67} {incr i 1} {
set tap($i) [new Agent/Tap];         # Create a TCPTap Agent
set ipnet($i) [new Network/IP];        # Create a Network agent
$ipnet($i) open writeonly
$tap($i) network $ipnet($i);              # Connect network agent to tap agent
$ns attach-agent $n($i) $tap($i);         # Attach agent to the node.
}

# ******** Configure the entry point ********
set k 67
for {set i 0} {$i < 67} {incr i 1} {
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
set delay_RTU [new RandomVariable/Normal]
$delay_RTU set avg_ 400
$delay_RTU set std_ 50

# --- RTU-SCADA_1 ---
for {set i 0} {$i < 20} {incr i 1} {
$ns duplex-link $n($i) $n(63) 2Mb [$delay_RTU value]ms DropTail
}

# --- RTU-SCADA_2 ---
for {set i 20} {$i < 40} {incr i 1} {
$ns duplex-link $n($i) $n(64) 2Mb [$delay_RTU value]ms DropTail
}

# --- RTU-SCADA_3 ---
for {set i 40} {$i < 63} {incr i 1} {
$ns duplex-link $n($i) $n(65) 2Mb [$delay_RTU value]ms DropTail
}

# --- SCADA-EMS ---
for {set i 63} {$i < 66} {incr i 1} {
$ns duplex-link $n($i) $n(66) 2Mb 100ms DropTail
}

# ******** Set up transportation level connections ********
# --- EMS ---
set null_n(66) [new Agent/Null]
    $ns attach-agent $n(66) $null_n(66)

# --- RTU ---
for {set i 0} {$i < 63} {incr i 1} {
set udp_n($i) [new Agent/UDP]
    $ns attach-agent $n($i) $udp_n($i)
}

# --- SCADA ---
for {set i 63} {$i < 66} {incr i 1} {
set a n($i)
set m [eval $$a get-module "MPLS"]
$m enable-reroute "new"
[$n($i) get-module "MPLS"] enable-data-driven
}

# ******** Setup traffic ********
for {set i 0} {$i < 63} {incr i 1} {
set cbr_n($i) [new Application/Traffic/CBR]
    $cbr_n($i) set interval_ 0.2
    $cbr_n($i) set packet_size_ 1000
    $cbr_n($i) attach-agent $udp_n($i)
}

for {set i 0} {$i < 63} {incr i 1} {
$ns connect $udp_n($i) $null_n(66)
    $udp_n($i) set fid_ $i
}

# --- RTU-SCADA_1 ---
for {set i 0} {$i < 20} {incr i 1} {
$ns queue-limit $n($i) $n(63) 10                
}

# --- RTU-SCADA_2 ---
for {set i 20} {$i < 40} {incr i 1} {
$ns queue-limit $n($i) $n(64) 10
}

# --- RTU-SCADA_3 ---
for {set i 40} {$i < 63} {incr i 1} {
$ns queue-limit $n($i) $n(65) 10
}

# --- SCADA-EMS ---
for {set i 63} {$i < 66} {incr i 1} {
$ns queue-limit $n($i) $n(66) 100
}

# ******** Transmission drop model ********
set em_RTU [new ErrorModel]
$em_RTU set rate_ 0.02;
$em_RTU unit pkt
$em_RTU ranvar [new RandomVariable/Uniform]
$em_RTU drop-target [new Agent/Null]

set em_SCADA [new ErrorModel]
$em_SCADA set rate_ 0.01;
$em_SCADA unit pkt
$em_SCADA ranvar [new RandomVariable/Uniform]
$em_SCADA drop-target [new Agent/Null]

# --- RTU-SCADA_1 ---
for {set i 0} {$i < 20} {incr i 1} {
$ns link-lossmodel $em_RTU $n($i) $n(63)
}

# --- RTU-SCADA_2 ---
for {set i 20} {$i < 40} {incr i 1} {
$ns link-lossmodel $em_RTU $n($i) $n(64)
}

# --- RTU-SCADA_3 ---
for {set i 40} {$i < 63} {incr i 1} {
$ns link-lossmodel $em_RTU $n($i) $n(65)
}

# --- SCADA-EMS ---
for {set i 63} {$i < 66} {incr i 1} {
$ns link-lossmodel $em_SCADA $n($i) $n(66)
}

# ******** Start up the sources ********
for {set i 0} {$i < 63} {incr i 1} {
$ns at 0 "$cbr_n($i) start"
}

for {set i 0} {$i < 63} {incr i 1} {
$ns at 3800 "$cbr_n($i) stop"
}

proc finish {} { 
	global ns f
	$ns flush-trace
	close $f
	exit 0
}

$ns at 4000.0 "finish"

$ns run


