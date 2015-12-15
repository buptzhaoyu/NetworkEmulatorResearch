#!/bin/bash


# Interface connect to phone
int1="usb0"
# Interface virtual for incomming traffic
tin1="ifb0"
# output and input rate
out="7.1mbit"
in="16.3mbit"

# It's necessary load this module in the kernel for do it
modprobe ifb numifbs=1
ip link set dev $tin1 up


# Clean interface
tc qdisc del root dev $int1
## Limit outcomming traffic (to phone)
tc qdisc add dev $int1 root netem rate ${out} delay 18ms

## Limit incomming traffic ( from phone)
# Clean interface
tc qdisc del dev $int1 handle ffff: ingress
tc qdisc del root dev $tin1

# Redirecto ingress $int1 to egress $tin1
tc qdisc add dev $int1 handle ffff: ingress
tc filter add dev $int1 parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev $tin1
## Limit incomming traffic
tc qdisc add dev $tin1 root netem rate $in delay 18ms


while read line
do
## Limit outcomming traffic (to phone)
tc qdisc change dev $int1 root netem rate ${line} delay 18ms
#tc qdisc del root dev $tin1
#tc qdisc add dev $tin1 root netem rate ${line} delay 18ms
sleep 1
done < OBWCS
