#! /bin/bash 

# see ~/.fvwm/minicom/README for details on how this works 

$XSOUNDCMD $XSOUNDPATH/newwindow.wav & 
rm ~/.minirc.dfl
ln -s ~/.fvwm/minicom/minirc.ttyUSB0.38400 ~/.minirc.dfl

/Skel/bin/urxvt -fn $XTERM_FONT_DEFAULT -fg yellow -bg $XTERM_DEFAULT_BG -title "Minicom 38400" -e minicom &

