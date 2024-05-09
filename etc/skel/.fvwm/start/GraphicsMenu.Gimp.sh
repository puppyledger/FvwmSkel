#! /bin/bash 

### ICON 

### VECTOR 

source $HOME/.pdtrc

if [ $PDT_ART_PATH ]
then
export HOME=$PDT_ART_PATH
fi

### SOUND 

$XSOUNDCMD $XSOUNDPATH/officeapp.wav &

### RUN 

/usr/bin/gimp & 

