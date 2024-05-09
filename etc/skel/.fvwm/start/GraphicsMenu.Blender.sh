#! /bin/bash 

### ICON 

$XTOOLPATH/FvwmCommand 'Style "*Blender*" Icon $[XICONPATH]/blue/screen.png' 
$XTOOLPATH/FvwmCommand 'Style "*Blender*" StartIconic' 

### VECTOR 

source $HOME/.pdtrc

if [ $PDT_VIDEO_PATH ]
then
export HOME=$PDT_VIDEO_PATH
fi

# then bong a sound

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &


/bin/blender & 

