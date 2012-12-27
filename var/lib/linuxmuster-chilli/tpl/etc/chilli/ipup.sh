#!/bin/sh
   #
   # Firewall script for ChilliSpot
   # A Wireless LAN Access Point Controller
   #
   # Uses $EXTIF (eth0) as the external interface (Internet or intranet) and
   # $INTIF (eth1) as the internal interface (access points).
   #
   #
   # SUMMARY
   # * All connections originating from chilli are allowed.
   # * Only ssh is allowed in on external interface.
   # * Nothing is allowed in on internal interface.
   # * Forwarding is allowed to and from the external interface, but disallowed
   #   to and from the internal interface.
   # * NAT is enabled on the external interface.

   IPTABLES="/sbin/iptables"
   EXTIF="eth0"
   INTIF="eth1"

   $IPTABLES -P INPUT DROP
   $IPTABLES -P FORWARD ACCEPT
   $IPTABLES -P OUTPUT ACCEPT

   #Allow related and established on all interfaces (input)
   $IPTABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

   #Allow releated, established and ssh on $EXTIF. Reject everything else.
   $IPTABLES -A INPUT -i $EXTIF -p tcp -m tcp --dport 22 --syn -j ACCEPT
   $IPTABLES -A INPUT -i $EXTIF -j REJECT

   #Allow related and established from $INTIF. Drop everything else.
   $IPTABLES -A INPUT -i $INTIF -j DROP

   #Allow http and https on other interfaces (input).
   #This is only needed if authentication server is on same server as chilli
   $IPTABLES -A INPUT -p tcp -m tcp --dport 80 --syn -j ACCEPT
   $IPTABLES -A INPUT -p tcp -m tcp --dport 443 --syn -j ACCEPT

   #Allow 3990 on other interfaces (input).
   $IPTABLES -A INPUT -p tcp -m tcp --dport 3990 --syn -j ACCEPT

   # This rule prevents hosts on the subscriber network to reach the
   # local proxy directly via port 8080
   $IPTABLES -I PREROUTING -t mangle -p tcp -s @@hs_network@@/@@hs_netmask@@ -d @@hs_ip@@ --dport 8080 -j DROP
   # This rule forwards all port 80 traffic to the local ffproxy for logging
   $IPTABLES -I PREROUTING -t nat -i $TUNTAP -p tcp -s @@hs_network@@/@@hs_netmask@@ ! -d @@hs_ip@@ --dport 80 -j REDIRECT --to 8080


   #Allow everything on loopback interface.
   $IPTABLES -A INPUT -i lo -j ACCEPT

   # Drop everything to and from $INTIF (forward)
   # This means that access points can only be managed from ChilliSpot
   $IPTABLES -A FORWARD -i $INTIF -j DROP
   $IPTABLES -A FORWARD -o $INTIF -j DROP

   #Enable NAT on output device
   $IPTABLES -t nat -A POSTROUTING -o $EXTIF -j MASQUERADE
