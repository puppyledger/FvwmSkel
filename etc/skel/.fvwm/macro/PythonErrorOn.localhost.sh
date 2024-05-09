#! /bin/bash 

# show the last python error (in conjunction with vipy and savepy)

export _GEOM1='120x36+0+0'
export _GEOM2='120x36+115+95'
export _GEOM3='120x36+250+175'
export _GEOM4='120x36+360+220'
export _GEOM5='120x36-50-50'
export _GEOM8='120x36-0-0'

export _GEOM6='140x38+120+0'
export _GEOM7='140x18+120-0'

source ~/.bashrc
cd $PDT_BIN_PATH

urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM6 -n $HOSTNAME -title $PWD -sr -e less ~/.pythonerror &

