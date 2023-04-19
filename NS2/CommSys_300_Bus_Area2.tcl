# ******** Creating new simulator ********
set ns [new Simulator]

# ******** Setting up the traces ********
set f [open Results_300_Bus_Area2.tr w]
$ns trace-all $f

$ns use-scheduler Simulink

# ******** Create nodes ********
# --- PMU ---
for {set i 0} {$i < 80} {incr i 1} {
set n($i) [$ns node]
}

# --- PDC ---
for {set i 80} {$i < 84} {incr i 1} {
set n($i) [$ns mpls-node]
}

# --- EMS ---
set n(84) [$ns node]

set c 22200

# ******** Configure the exit point ********
for {set i 0} {$i  < 85} {incr i 1} {
set tap($i) [new Agent/Tap];         # Create a TCPTap Agent
set ipnet($i) [new Network/IP];        # Create a Network agent
$ipnet($i) open writeonly
$tap($i) network $ipnet($i);              # Connect network agent to tap agent
$ns attach-agent $n($i) $tap($i);         # Attach agent to the node.
}

# ******** Configure the entry point ********
set k 85
for {set i 0} {$i < 85} {incr i 1} {
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
set delay_PMU [new RandomVariable/Normal]
$delay_PMU set avg_ 1000
$delay_PMU set std_ 150

# --- PMU-PDC_1 ---
for {set i 0} {$i < 20} {incr i 1} {
$ns duplex-link $n($i) $n(80) 2Mb [$delay_PMU value]ms DropTail
}

# --- PMU-PDC_2 ---
for {set i 20} {$i < 40} {incr i 1} {
$ns duplex-link $n($i) $n(81) 2Mb [$delay_PMU value]ms DropTail
}

# --- PMU-PDC_3 ---
for {set i 40} {$i < 60} {incr i 1} {
$ns duplex-link $n($i) $n(82) 2Mb [$delay_PMU value]ms DropTail
}

# --- PMU-PDC_4 ---
for {set i 60} {$i < 80} {incr i 1} {
$ns duplex-link $n($i) $n(83) 2Mb [$delay_PMU value]ms DropTail
}

# --- PDC-EMS ---
for {set i 80} {$i < 84} {incr i 1} {
$ns duplex-link $n($i) $n(84) 2Mb 100ms DropTail
}

# ******** Set up transportation level connections ********
# --- EMS ---
set null_n(84) [new Agent/Null]
    $ns attach-agent $n(84) $null_n(84)

# --- PMU ---
for {set i 0} {$i < 80} {incr i 1} {
set udp_n($i) [new Agent/UDP]
    $ns attach-agent $n($i) $udp_n($i)
}

# --- PDC ---
for {set i 80} {$i < 84} {incr i 1} {
set a n($i)
set m [eval $$a get-module "MPLS"]
$m enable-reroute "new"
[$n($i) get-module "MPLS"] enable-data-driven
}

# ******** Setup traffic ********
for {set i 0} {$i < 80} {incr i 1} {
set cbr_n($i) [new Application/Traffic/CBR]
    $cbr_n($i) set interval_ 2
    $cbr_n($i) set packet_size_ 1000
    $cbr_n($i) attach-agent $udp_n($i)
}

for {set i 0} {$i < 80} {incr i 1} {
$ns connect $udp_n($i) $null_n(84)
    $udp_n($i) set fid_ $i
}

# --- PMU-PDC_1 ---
for {set i 0} {$i < 20} {incr i 1} {
$ns queue-limit $n($i) $n(80) 100
}

# --- PMU-PDC_2 ---
for {set i 20} {$i < 40} {incr i 1} {
$ns queue-limit $n($i) $n(81) 100
}

# --- PMU-PDC_3 ---
for {set i 40} {$i < 60} {incr i 1} {
$ns queue-limit $n($i) $n(82) 100
}

# --- PMU-PDC_4 ---
for {set i 60} {$i < 80} {incr i 1} {
$ns queue-limit $n($i) $n(83) 100
}

# --- PDC-EMS ---
for {set i 80} {$i < 84} {incr i 1} {
$ns queue-limit $n($i) $n(84) 1000
}

# ******** Transmission drop model ********
set em_PMU [new ErrorModel]
$em_PMU set rate_ 0.02;
$em_PMU unit pkt
$em_PMU ranvar [new RandomVariable/Uniform]
$em_PMU drop-target [new Agent/Null]

set em_PDC [new ErrorModel]
$em_PDC set rate_ 0.01;
$em_PDC unit pkt
$em_PDC ranvar [new RandomVariable/Uniform]
$em_PDC drop-target [new Agent/Null]

# --- PMU-PDC_1 ---
for {set i 0} {$i < 20} {incr i 1} {
$ns link-lossmodel $em_PMU $n($i) $n(80)
}

# --- PMU-PDC_2 ---
for {set i 20} {$i < 40} {incr i 1} {
$ns link-lossmodel $em_PMU $n($i) $n(81)
}

# --- PMU-PDC_3 ---
for {set i 40} {$i < 60} {incr i 1} {
$ns link-lossmodel $em_PMU $n($i) $n(82)
}

# --- PMU-PDC_4 ---
for {set i 60} {$i < 80} {incr i 1} {
$ns link-lossmodel $em_PMU $n($i) $n(83)
}

# --- PDC-EMS ---
for {set i 80} {$i < 84} {incr i 1} {
$ns link-lossmodel $em_PDC $n($i) $n(84)
}

# ******** Start up the sources ********
for {set i 0} {$i < 80} {incr i 1} {
$ns at 0 "$cbr_n($i) start"
}

for {set i 0} {$i < 80} {incr i 1} {
$ns at 85 "$cbr_n($i) stop"
}

proc finish {} { 
	global ns f
	$ns flush-trace
	close $f
	exit 0
}

$ns at 4000.0 "finish"

$ns run


