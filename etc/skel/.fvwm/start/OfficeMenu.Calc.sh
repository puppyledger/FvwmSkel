#! /bin/bash 

### ICON 

$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - C*" Icon $[XICONPATH]/white/pie--chart.png' 
$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - C*" StartIconic' 

### VECTOR 

source $HOME/.pdtrc

if [ $PDT_DATA_PATH ]
then
export HOME=$PDT_DATA_PATH
fi

### SOUND

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN

# this starts calc with a socket for exporting access to API code. 

export PYSCRIPT_LOG_LEVEL=DEBUG

# $XOFFICEPATH/scalc --nologo --nofirststartwizard --norestore --accept="socket,host=localhost,port=2002;urp;StarOffice.ServiceManager" & 

# DEBUG MODE (doesn't seem to do anything

urxvt -e $XOFFICEPATH/scalc -env:PYSCRIPT_LOG_LEVEL=DEBUG --nologo --nofirststartwizard --norestore --accept="socket,host=localhost,port=2002;urp;StarOffice.ServiceManager" & 

