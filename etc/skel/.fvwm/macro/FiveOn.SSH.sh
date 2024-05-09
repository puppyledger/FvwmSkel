#! /bin/bash 

# This macro starts 3 tiled terminals for working, and 2 wide terminals for 
# logging across two adjacent pages. 

# 1600x900 display geometries 

export SSHQUESTION="SSH Host:"
export SSHDEFAULTHOST=www

export SSHHOST=`$XTOOLPATH/fvwm-entry -d $SSHDEFAULTHOST -m "$SSHQUESTION"`
export _GEOM1='160x38+0+0'
export _GEOM2='160x38+280+180'
export _GEOM3='160x38-0-0'
export _GEOM4='140x32+340-0'
export _GEOM5='140x31+340+0'

echo $USER@$SSHHOST
exit 

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr -e ssh -p 22 $USER@$SSHHOST &

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM2 -n $HOSTNAME -title $PWD -sr -e ssh -p 22 $USER@$SSHHOST &

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM3 -n $HOSTNAME -title $PWD -sr -e ssh -p 22 $USER@$SSHHOST &

sleep 1
FvwmCommand 'GotoPage wrapx wrapy +1p +0p'

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM4 -n $HOSTNAME -title $PWD -sr -e ssh -p 22 $USER@$SSHHOST &

urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM5 -n $HOSTNAME -title $PWD -sr -e ssh -p 22 $USER@$SSHHOST &

sleep 1 

FvwmCommand 'GotoPage wrapx wrapy -1p +0p'
FvwmCommand 'Warp2Next'

