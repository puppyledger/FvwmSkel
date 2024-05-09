To use the minicom ports you need to add yourself to group dialout.  
The kernel (should) by default set /dev/ttyUSB0 to root:dialout 0660
The script run from the dropdown, should symlink in one of the rc 
files in this directory into our ~/.minirc.dfl file, and then run 
minicom against it. It is possible to use the evironment variable 
trick, but this way seems more persistent/portable  

# adding a user to a group 
usermod -a -G dialout <useid>

