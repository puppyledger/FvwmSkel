#! /bin/bash 

# 6 windows across 2 pages

export _GEOM1='120x36+0+0'
export _GEOM2='120x36+124+100'
export _GEOM3='120x36+314+212'
export _GEOM4='120x36-0-0'

export _GEOM5='140x38+120+0'
export _GEOM6='140x18+120-0'

urxvt +ptab -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr &
urxvt +ptab -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM2 -n $HOSTNAME -title $PWD -sr &
urxvt +ptab -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM3 -n $HOSTNAME -title $PWD -sr &
urxvt +ptab -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM4 -n $HOSTNAME -title $PWD -sr &

sleep 2

FvwmCommand 'GotoPage wrapx wrapy +1p +0p'

urxvt +ptab -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM5 -n $HOSTNAME -title $PWD -sr &
urxvt +ptab -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM6 -n $HOSTNAME -title $PWD -sr &

sleep 1 

FvwmCommand 'GotoPage wrapx wrapy -1p +0p'

FvwmCommand 'Warp2Next'

