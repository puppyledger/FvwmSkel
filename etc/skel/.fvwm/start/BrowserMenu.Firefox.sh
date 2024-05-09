#! /bin/bash 

### ICON

$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - W*" Icon $[XICONPATH]/white/edit.png' 
$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - W*" StartIconic' 

### VECTOR

source $HOME/.pdtrc

if [ $PDT_RESOURCE_PATH ]
then
export HOME=$PDT_RESOURCE_PATH
fi

### SOUND

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN

# browsers should be compartmentalized. We should probably create /usr/browser or something. 

/usr/bin/firefox &  
