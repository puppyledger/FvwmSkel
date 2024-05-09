#! /bin/bash 

# some environment variables may be dynamic, 
# so we make sure we get the latest versions 

source $HOME/.bashrc

# It takes a LOT of external tools and files to make Fvwm pretty 
# so we have lots of places to put them. Note: the paths here 
# shouldn't be stacked, as they are interpolated, not sourced.  

export XFVWMPATH=$HOME/.fvwm/fvwm					# where most of the fvwm config stuff is	
export XFVWMCMD=/usr/bin/FvwmCommand				# where the FvwmCommand injector is located	
export XTOOLPATH=$HOME/.fvwm/bin						# custom tools for fvwm
export XOFFICEPATH=/usr/lib/libreoffice/program	# where scalc,stext etc are install. 
export XWININFOCMD="/bin/xwininfo" 					# xwininfo is used by some tools for getting geometry
export XMESSAGECMD="/bin/xmessage" 					# xmessage is mostly for diag
export XWALLPAPERPATH="$HOME/.fvwm/.wallpaper"		# system wallpapers
export XWALLPAPERCMD=$'\"/bin/qiv -x\"'			# program to swap wallpapers
export XICONPATH="$HOME/.fvwm/.icon"			# icons for fvwm
export XSOUNDPATH="$HOME/.fvwm/.sound"			# sounds for fvwm
export XSOUNDCMD="/bin/aplay"				# sounds for fvwm
export XFONTPATH="$HOME/.fvwm/.fonts"			# xterm font dir
export XTRYFONTCMD=$XTOOLPATH/urxvt-bounce		# xterm font try
export XSETFONTCMD=$XTOOLPATH/urxvt-setfont		# xterm font set
export XLOGPATH=$HOME/.fvwm2.log			# where fvwm should log
export XSTARTPATH=$HOME/.fvwm/start			# "Start" scripts
export XMACROPATH=$HOME/.fvwm/macro			# "Macros" use FvwmCommand to generate certain X behaviors
export XSKELLIB=$HOME/.fvwm/lib/perl5

# Fvwm is single threaded, so we cannot read and write to it 
# at the same time. Sometimes tmp files are the best way
# of working around that. See the rtfn command (part of Bash::Sugar) 
# if you need to use temp files. 

export XTMPPATH=$HOME/.tmp				# Tmp files 
export XTMPEXPIRE=3600					# Tmp files delete after an hour 

# Many of the tools in FvwmSkel are written in perl5, but the 
# perl path for Pdt is dynamic. So we have to create a base 
# path in an independent file.

eval `/usr/bin/egrep 'export\s+PERL5LIB=' $HOME/.perlrc`

# HOMESTATION is set by .xinitrc, CURRENTSTATION is set by .bashrc.  
# Therefore if we copy our .xinitrc AND|OR .bashrc to other hosts, 
# runtime scripts can know whether they are on the xclient or not
# by comparing the two. (and run differently)

export HOMESTATION=`$XTOOLPATH/hostonly` # needs to be added to Bash::Sugar

# allow scripts to have a user defined path to iptables (is this useful?) 
# export XIPTABLESPATH=/usr/bin/iptables

# bells are for raindeer
xset -b 

# always start x in our home directory
cd $HOME

# always look for new fonts before startup
/bin/fc-cache

xset +fp $HOME/.fonts
xset +fp $HOME/.xuserfonts

# Disable touchpad while typing. 
syndaemon -i 1 -t -d

# Start the users pulseaudio sound server
# start-pulseaudio-x11 &

# Set the vga port to display the same as the main screen 
xrandr --output VGA-0 --same-as eDP

# Run the window manager
cd $HOME
exec /bin/fvwm -display :0 >& $HOME/.fvwm2.log
# exec /usr/bin/startplasma-x11

# tell X to read our Xresources file 
xrdb -merge $HOME/.Xresources


