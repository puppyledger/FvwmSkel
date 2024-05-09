#! /bin/bash 

# set a default background

/bin/qiv -x $XWALLPAPERPATH/baroque.jpg & 

# set five terminals on localhost

# This is run somewhere in the .fvwmrc config files. 
# Currently it is setup to work with PDT, such that 
# the session starts with the top row in the current 
# project bin directory, second row in the current 
# project lib directory, and third row in $HOME. 

FvwmCommand 'GotoPage 0 0'
# project ODSL
# $XMACROPATH/SixODSLOn.localhost.sh
cd $PDT_BIN_PATH
$XMACROPATH/SixOn.localhost.sh
sleep 1

FvwmCommand 'GotoPage wrapx wrapy +0p +1p'
cd $PDT_LIB_PATH
$XMACROPATH/SixOn.localhost.sh
sleep 1

FvwmCommand 'GotoPage wrapx wrapy +0p +1p'
cd $HOME
$XMACROPATH/SixOn.localhost.sh

# set a block of 5 terminals ssh'd into a remote host

# here if we want, we can define a PDT working host
# variable and then have this automatically connect 
# us to our last working host. (just an idea) 

# $XMACROPATH/SixOn.workinghost.sh & 
