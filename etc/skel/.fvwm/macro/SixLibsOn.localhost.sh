#! /bin/bash 

# 6 windows in the current projects bin directory across 2 virtual desktops

export _GEOM1='120x36+0+0'
export _GEOM2='120x36+115+95'
export _GEOM3='120x36+250+175'
export _GEOM4='120x36+360+260'
export _GEOM5='120x36-0-0'

export _GEOM6='140x38+120+0'
export _GEOM7='140x18+120-0'

source ~/.bashrc
cd $PDT_LIB_PATH

urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM2 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM3 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM4 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM5 -n $HOSTNAME -title $PWD -sr &

sleep 2

FvwmCommand 'GotoPage wrapx wrapy +1p +0p'

urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM6 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM7 -n $HOSTNAME -title $PWD -sr &

sleep 1 

FvwmCommand 'GotoPage wrapx wrapy -1p +0p'
FvwmCommand 'Warp2Next'
