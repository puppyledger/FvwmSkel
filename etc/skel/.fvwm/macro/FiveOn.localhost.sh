#! /bin/bash 

# 5 windows across 2 pages

export _GEOM1='120x36+0+0'
export _GEOM2='120x36+105+120'
export _GEOM3='120x36-0-0'
export _GEOM4='140x28+120-0'
export _GEOM5='140x27+120+0'

urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM2 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM3 -n $HOSTNAME -title $PWD -sr &

sleep 2

FvwmCommand 'GotoPage wrapx wrapy +1p +0p'

urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM4 -n $HOSTNAME -title $PWD -sr &
urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM5 -n $HOSTNAME -title $PWD -sr &

sleep 1 

FvwmCommand 'GotoPage wrapx wrapy -1p +0p'

FvwmCommand 'Warp2Next'

