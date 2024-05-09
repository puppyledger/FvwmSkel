#! /bin/bash 

### ICON

$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - D*" Icon $[XICONPATH]/white/star.png' 
$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - D*" StartIconic' 

### VECTOR

source $HOME/.pdtrc

if [ $PDT_ART_PATH ]
then
export HOME=$PDT_ART_PATH
fi

### SOUND

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN

/usr/bin/firefox &
