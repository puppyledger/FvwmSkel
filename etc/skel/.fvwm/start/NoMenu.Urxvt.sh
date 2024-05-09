#! /bin/bash 

# uncomment to troubleshoot

#echo "xtermlinebuf: $XTERM_LINEBUF"
#echo "deffg: $XTERM_DEFAULT_FG"
#echo "defbg: $XTERM_DEFAULT_BG"
#echo "size: $XTERM_SIZE_DEFAULT"
#echo "host: $CURRENTSTATION"
#echo "pwd: $PWD"
#echo "user: $USER"

# do our styles
# $XTOOLPATH/FvwmCommand 'Style "$[USER]*" Icon $[XICONPATH]/white/screen.png' 
# $XTOOLPATH/FvwmCommand 'Style "$[USER]*" StartIconic' 

# bonk a sound
$XSOUNDCMD $XSOUNDPATH/newwindow.wav & 

# Whoopee! 
urxvt -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $XTERM_SIZE_DEFAULT -n $CURRENTSTATION -title $PWD -sr & 

