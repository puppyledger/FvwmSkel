#! /bin/bash 

### ICON 

$XTOOLPATH/FvwmCommand 'Style "*Blender*" Icon $[XICONPATH]/blue/screen.png' 
$XTOOLPATH/FvwmCommand 'Style "*Blender*" StartIconic' 

### VECTOR 

source $HOME/.pdtrc

# then bong a sound

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

xterm -e "ls -la $HOME/.wine/drive_c/'Program Files'/SketchUp/'SketchUp 2016'/ ; echo $HOME ;  sleep 10"
xterm -e "/usr/bin/wine $HOME/.wine/drive_c/'Program Files'/SketchUp/'SketchUp 2016'/Sketchup.exe ; echo $HOME ;  sleep 10"

