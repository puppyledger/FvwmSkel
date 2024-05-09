#! /bin/bash 

### ICON

$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - W*" Icon $[XICONPATH]/white/edit.png' 
$XTOOLPATH/FvwmCommand 'Style "*LibreOffice - W*" StartIconic' 

### VECTOR

source $HOME/.pdtrc

if [ $PDT_OFFICE_PATH ]
then
export HOME=$PDT_OFFICE_PATH
fi

### SOUND

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN

$XOFFICEPATH/swriter --norestore --nologo --nolockcheck & 

