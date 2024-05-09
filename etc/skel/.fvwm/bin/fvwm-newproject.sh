#! /bin/bash

# fvwm-getnewproject solicits the user for a new 
# project directory and then runs the script 
# defined in $XNEWPROJECTSCRIPT which typically 
# points to this script. 

### $XUSERPROJECTPATH is defined in $HOME/.usersetup 

export THISPROJECTPATH=$1

# this blocks. Which allows the user to kill this script 
# if they made a mistake. 

$XMESSAGECMD "Making Project Path:  $THISPROJECTPATH" 

# interpolate the directores

export XPROJECTDOCPATH=$THISPROJECTPATH/Doc                # swriter
export XPROJECTDATPATH=$THISPROJECTPATH/Data               # scalc/sbase
export XPROJECTBINPATH=$THISPROJECTPATH/bin                # private scripts 
export XPROJECTLIBPATH=$THISPROJECTPATH/lib                # libraries related to the project
export XPROJECTARTPATH=$THISPROJECTPATH/Art     	   # for the composition of still art.  
export XPROJECTSOUNDPPATH=$THISPROJECTPATH/Sound     	   # for audio track collection and composition
export XPROJECTCADPATH=$THISPROJECTPATH/Model              # for Cad
export XPROJECTGITPATH=$THISPROJECTPATH/Git                # for Git projects

export XPROJECTVGAPATH=$THISPROJECTPATH/Video/VGA          # for videos of the respective 
export XPROJECT480PPATH=$THISPROJECTPATH/Video/480P        # resoultions
export XPROJECT720PPATH=$THISPROJECTPATH/Video/720P        # 
export XPROJECT1080PPATH=$THISPROJECTPATH/Video/1080P      # 
export XPROJECTSTILLPATH=$THISPROJECTPATH/Video/Still      # for still images destined for video import. 
export XPROJECTAUDIOPATH=$THISPROJECTPATH/Video/Audio      # for for audio tracks destined for video import. 
export XPROJECTBLENDPATH=$THISPROJECTPATH/Video/Project    # for blender files

# then make them

if [ ! -d $THISPROJECTPATH ]; then 
	mkdir -p $THISPROJECTPATH
fi

if [ ! -d $XPROJECTDOCPATH ]; then 
	mkdir -p $XPROJECTDOCPATH
fi

if [ ! -d $XPROJECTDATPATH ]; then 
	mkdir -p $XPROJECTDATPATH
fi

if [ ! -d $XPROJECTBINPATH ]; then 
	mkdir -p $XPROJECTBINPATH
fi

if [ ! -d $XPROJECTLIBPATH ]; then 
	mkdir -p $XPROJECTLIBPATH
fi

if [ ! -d $XPROJECTVGAPATH ]; then 
	mkdir -p $XPROJECTVGAPATH
fi

if [ ! -d $XPROJECT480PPATH ]; then 
	mkdir -p $XPROJECT480PPATH
fi

if [ ! -d $XPROJECT720PPATH ]; then 
	mkdir -p $XPROJECT720PPATH
fi

if [ ! -d $XPROJECT1080PPATH ]; then 
	mkdir -p $XPROJECT1080PPATH
fi

if [ ! -d $XPROJECTBLENDPPATH ]; then 
	mkdir -p $XPROJECTBLENDPATH
fi

if [ ! -d $XPROJECTSOUNDPPATH ]; then 
	mkdir -p $XPROJECTSOUNDPATH
fi

if [ ! -d $XPROJECTCADPATH ]; then 
	mkdir -p $XPROJECTCADPATH
fi

if [ ! -d $XPROJECTGITPATH ]; then 
	mkdir -p $XPROJECTGITPATH
fi

