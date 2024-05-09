package Pdt::INSTALL::Bashrc;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__
# DON'T EDIT HERE! This file sources ~/.alias 
# and ~/.usersetup for localized settings. Any 
# variables defined here can be overridden 
# in either of those two files. 

# You should expect FvwmSkeleton to overwrite 
# this file. It contains paths that are critical 
# to most of the scripts that make FvwmSkeleton 
# nice and cozy. 

# NOTE: if you are getting a rxvt-unicode unknown 
# terminal type error, you need to install the 
# correct terminfo files in the terminfo database. 
# Typically: /Skel/share/terminfo/r/ but there may 
# be other locations. 

# The current version of fvwm skeleton user 
# environment

export SKELVERSION="1.5"

# We use different prompts depending on connection type.  
# xterms are configured to use window titles as paths, so 
# we don't include explicit path information for them. 
# vt100 connections should only occur during emergency 
# maintainance, so we log them for security. This is bash, 
# but we use a tcsh style prompt for less eye strain. 

if [ $TERM == 'vt100' ]
then
logger -p 'local1.info' -s "$USER logged into $HOSTNAME on serial console: $TERM"
export PS1="\u@\h:\w->"
fi 

if [ $TERM == 'linux' ]
then
export PS1="\u@\h:\w->"
fi

if [ $TERM == 'xterm' ]
then
export PS1="\u@\h->"
fi 

if [ $TERM == 'rxvt-unicode' ]
then
export PS1="\u@\h->"
fi 

### We keep a lot of bash history

export HISTSIZE=1000

# but we don't keep a less history

export LESSHISTFILE='-'

# GUI configuration goes here 

export XFVWMPATH=$HOME/.fvwm/fvwm

# programs to sweeten FVWM go here. 

export XTOOLPATH=$HOME/.fvwm/bin

# the location of libreoffice

export XOFFICEPATH=/Skel/bin/libreoffice5.3/program

# xwininfo is used for extracting window geometry, title and 
# other parameters to do intelligent window and icon handling.  

export XWININFOCMD="/bin/xwininfo" 

# xmessage is used to throw some errors. 

export XMESSAGECMD="/bin/xmessage" 

# qiv is used for setting the wallpaper in the background

export XWALLPAPERCMD=$'\"/bin/qiv -x\"'

# note that the following cofigurations all have 
# paths for both system and user. Users, if 
# inclined may redefine some of these 
# search paths by uncommenting the respective 
# user settings in .usersetup,which will 
# override the ones here. 

# Simple Menu start scripts go here

export XSTARTPATH=$HOME/.fvwm/start
export XUSERSTARTPATH=$HOME/.xuserstart

# Complex Menu executed scripts go here  

export XMACROPATH=$HOME/.fvwm/macro
export XUSERMACROPATH=$HOME/.xusermacro

# icons for fvwm

export XICONPATH="$HOME/.fvwm/.icon"
export XUSERICONPATH="$HOME/.xusericon"

# sounds for fvwm 

export XSOUNDPATH="$HOME/.fvwm/.sound"
export XUSERSOUNDPATH="$HOME/.xusersound"

### FONTS 

# $HOME/.fonts is automatically searched by X.  
# however index files fonts.dir and fonts.scale 
# must exist in this directory for X to see 
# the fonts. These are created by the programs 
# mkfontdir and mkfontscale 

# .fonts.conf tells X to also check the users 
# font configuration directory. We are  
# specifying the filename here for clarity 
# though it is read by X by default. 

export FONTCONFIG_FILE=$HOME/.fonts.conf

# $HOME/.fonts is also the default for X. 
# We however are symlinking this to  
# distro included fonts. So we can 
# then specify an additional user fonts 
# directory in fonts.conf which is 
# $HOME/.xuserfonts, which the user 
# can add fonts to at their liesure 
# and then run mkfontdir and mkfontscale. 

export XFONTPATH="$HOME/.fvwm/.fonts"
export XUSERFONTPATH="$HOME/.xuserfonts"

# the titlebar menu has some selections  
# for fonts. Once selected programs have to 
# be run to actually set those fonts. 
# See $XFVWMPATH/TitlebarMenu.fvwm, and 
# $XMACROPATH/Urxvt.TryFont.txt and 
# $XUSERFONTPATH/Urxvt.UserFont.txt to 
# see how to update the list. 

export XTRYFONTCMD=$XTOOLPATH/urxvt-bounce
export XSETFONTCMD=$XTOOLPATH/urxvt-setfont 

# wallpaper for fvwm 

export XWALLPAPERPATH="$HOME/.fvwm/.wallpaper"
export XUSERWALLPAPERPATH="$HOME/.xuserwallpaper"

# this specifies fvwm's log location: 
# xinit zeros this at every load. 

export XLOGPATH=$HOME/.fvwm2.log

### this path searches for executables from most 
### personalized to least personalized locations. 
### it can be appended by doing an: i
### PATH="$PATH:<additionaldirectores>" 
### in .usersetup. 

export PATH="$XTOOLPATH:$XSTARTPATH:$XMACROPATH:$HOME/bin:/Skel/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin" 

# Some programs need to know whether they are running 
# on the machine in front of you, or on a remote host. 
# oncd for example uses different title styles depending
# on locality. If you don't know how important this is 
# you've never dumped a cut and paste into the wrong 
# window and wiped out half the Internet. (never 
# happens, right?) 
#
# To solve this problem we set two variables. 
# export HOMESTATION=$HOSTNAME is set in .xinitrc 
# and export CURRENTSTATION=$HOSTNAME happens in 
# .bashrc. By comparing, we can determine whether 
# we are on the X host, or a remote host. 

export CURRENTSTATION=`$XTOOLPATH/hostonly`

# This program runs at every prompt, and is what 
# send the terminal escape sequence that sets the titles.
# Other programs may also send terminal escapes. 
# Vim for example. 

export PROMPT_COMMAND="$XTOOLPATH/oncd"

### use this file for autocompletion of hostnames
### It is also used for some automation. Typically 
### it is just a symbolic link to /etc/hosts, but 
### not neccessarily. 

export HOSTFILE=$HOME/.hosts

### tell crontab we use our local editor (vim)  

export EDITOR=/Skel/bin/vi

### Where the fifo maker is. Fvwm isn't threaded. 
### so to do asynchronous IO we need to buffer the 
### loop. skel-getenv is an example of how this can
### be used. 

export PERL_MKFIFO='/usr/bin/mkfifo'

### a tmp directory for keeping temporary fifos

export PERL_TMP="/Skel/tmp"

### User configured alias go here. 

source $HOME/.alias

### PDT is an OO perl ide for vim. It includes 
### templating, factory classes and an object 
### registry. 

source $HOME/.pdtrc

### VTP Video Tools in Perl. Includes wrappers 
### for ffmpeg and qiv for screenrecording, 
### screen capturing, and audio recording. 
### CLI tools can then be used to normalize 
### recording. 

source $HOME/.vtprc

### .usersetup is reset with each new installation 
### but prior configurations should be backed up 
### to $HOME/.usersetup.(date) This simplifies 
### maintanance, and allows users to recover their 
### custom stuff after the administrator pushes  
### new configs and blows things up.

source $HOME/.usersetup

