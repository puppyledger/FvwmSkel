#! /bin/bash 

# set a default background


urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM1 -n $HOSTNAME -title $PWD -sr -e "bash" -c "rm $HOME/debug.txt ;$PDT_BIN_PATH/cll.pl -o $PDT_BIN_PATH/foo.db -d $HOME/debug.txt" &

sleep 3 ; 

urxvt -fn $XTERM_FONT_DEFAULT -sl $XTERM_LINEBUF -bg $XTERM_DEFAULT_BG -fg $XTERM_DEFAULT_FG -geometry $_GEOM2 -n $HOSTNAME -title $PWD -sr -e "bash" -c "tail -s 0.05 -F $HOME/debug.txt" &
