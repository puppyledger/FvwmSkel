#! /bin/bash 

### ICON 

$XTOOLPATH/FvwmCommand 'Style "*Base*" Icon $[XICONPATH]/white/server.png' 
$XTOOLPATH/FvwmCommand 'Style "*Base*" StartIconic' 

### VECTOR 

source $HOME/.pdtrc

if [ $PDT_DATA_PATH ]
then
export HOME=$PDT_DATA_PATH
fi

#### SOUND

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN

$XOFFICEPATH/sbase --nologo --nofirststartwizard --minimized & 

