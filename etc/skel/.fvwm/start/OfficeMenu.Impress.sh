#! /bin/bash 

### ICON 

$XTOOLPATH/FvwmCommand 'Style "*Impress*" Icon $[XICONPATH]/white/rss.png' 
$XTOOLPATH/FvwmCommand 'Style "*Impress*" StartIconic' 

### VECTOR 

source $HOME/.pdtrc

if [ $PDT_OFFICE_PATH ]
then
export HOME=$PDT_OFFICE_PATH
fi

### SOUND

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN

$XOFFICEPATH/simpress --nologo --nofirststartwizard & 

