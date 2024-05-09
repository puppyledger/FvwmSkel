#! /bin/bash 

### BACKUP TO LOCALHOST OR SPOOL

xterm -e "sudo $XTOOLPATH/qb -d $PDT_ROOT/$PDT_ACTIVE ; aplay $XSOUNDPATH/backupcomplete.wav ; $XTOOLPATH/waitreturn"

