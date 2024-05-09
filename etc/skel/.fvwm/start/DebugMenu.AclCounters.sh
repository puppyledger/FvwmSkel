#! /opt/bin/bash

# open up an xterm, reset ACL counters, and show counters.  

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr -e sudo iptables -Z ; xterm -e watch --interval 0 'iptables -nvL | grep -v "0 0"' 

