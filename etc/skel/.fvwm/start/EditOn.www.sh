#! /bin/bash 

# This macro starts 3 tiled terminals, 2 wide terminals across two pages. 
# each ssh'd into the respective host as user install. 

export _GEOM1='160x38+0+0'
export _GEOM2='160x38+105+120'
export _GEOM3='160x38-0-0'
export _GEOM4='140x28+120-0'
export _GEOM5='140x27+120+0'

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr -e ssh -p 5522 install@$1 &

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM2 -n $HOSTNAME -title $PWD -sr -e ssh -p 5522 install@$1 &

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM3 -n $HOSTNAME -title $PWD -sr -e ssh -p 5522 install@$1 &

sleep 1
FvwmCommand 'GotoPage wrapx wrapy +1p +0p'

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM4 -n $HOSTNAME -title $PWD -sr -e ssh -p 5522 install@$1 &

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM5 -n $HOSTNAME -title $PWD -sr -e ssh -p 5522 install@$1 &

sleep 1 

FvwmCommand 'GotoPage wrapx wrapy -1p +0p'
FvwmCommand 'Warp2Next'

