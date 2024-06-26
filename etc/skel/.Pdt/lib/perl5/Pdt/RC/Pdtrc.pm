package Pdt::RC::Pdtrc;

our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: .pdtrc template

__DATA__
#! /bin/bash

### STARTUP

# STOP! Do not edit this file. Edit below 
# the DATA line in the program setpdtrc. This 
# file is written and sourced dynamically and 
# frequently. .pdtrc should also be sourced 
# at the very end of your .bashrc like so: 
#
# 	source $HOME/.pdtrc

# this file. 

export PDT_PDTRC="$HOME/.pdtrc"

# the pdt base install and lib directories. 
# These are for the IDE installation, not 
# the directories your projects will go in.  

export PDT_INSTALL=/Skel/Pdt
export PDT_BIN=$PDT_INSTALL/bin
export PDT_LIB=$PDT_INSTALL/lib/perl5/local

# the perl intepreter we want our scripts to use

export PDT_PERL=/Skel/bin/perl

# Project root. This is where your projects 
# go. Pointing this at a symlink is OK. 

export PDT_ROOT=$HOME/Project

# PDT_UMASK, tells pdt what file permissions   
# to use by default. This is in umask format, 
# so it is backwards from chmod. ie. 
# chmod 0755 = umask 0022, PDT_GROUP tells 
# pdt tools what group to set files to by 
# default.  

export PDT_UMASK=0022
export PDT_GROUP=users

# PDT_ACTIVE designates the project currently being 
# edited. It is set using the -p <project> switch 
# in vimod or viexec where <project> is the one word 
# directory name of the desired project, AND the project 
# name in the master repo if you are using git. This 
# will be rewritten to .pdtrc, and sourced by all pdt 
# tools prior to execution. This allows the tools 
# to "vector" eachother towards a project, and stay 
# vectored. until changed. 
#
# NOTE: Not all which is project related, is 
# distributed. Which is why the SCM path is 
# double nested. 

export PDT_ACTIVE=EXAMPLE
export PDT_SCM_DIR=$PDT_ROOT/$PDT_ACTIVE/Git
export PDT_SCM_PATH=$PDT_SCM_DIR/$PDT_ACTIVE
export PDT_BIN_PATH=$PDT_SCM_PATH/bin
export PDT_LIB_PATH=$PDT_SCM_PATH/lib

# There is also a .pdtdir file that can be used to 
# autogenerate directory trees for the respective 
# project. These will be detected and built with 
# every new project. PDT_DIR_ON turns this feature on 
# automatically any time a new project is created.  
# it can also be manually actived with the -d option 
# to setpdtrc. 

export PDT_DIR=$HOME/.pdtdir 
export PDT_DIR_ON=1 

# pdt has the ability to wrap some git calls for the 
# the initial clone, and push functions of new projects. 
# To turn this on set this to 1. The if statement
# is to accomidate possible future integration of other 
# SCM systems. Of course to use git will need to be in 
# PATH which you set in .bashrc, right? 

export PDT_GIT_ON=1

if [ $PDT_GIT_ON == 1 ]
then 
export PDT_GIT_PATH=$PDT_SCM_PATH  
export PDT_GIT_USER=`git config --get user.name`  
export PDT_GIT_EMAIL=`git config --get user.email`  
export PDT_GIT_HOST='https://github.com'  
export PDT_GIT_REPO=$PDT_GIT_HOST/$PDT_GIT_USER/$PDT_ACTIVE
fi 

# reach back into $HOME/.bashrc and set our static paths, 
# and then add our dynamic ones. If your path is getting 
# broken, you need to make sure the grep line here matches 
# your PATH in in .bashrc. 

eval `/usr/bin/grep 'export PATH=' $HOME/.bashrc`
eval `/usr/bin/grep 'export PERL5LIB=' $HOME/.bashrc`

# now we we put the active project directories in our path 

export PATH="$PDT_BIN_PATH:$PDT_BIN:$PATH"	
export PERL5LIB="$PDT_LIB_PATH:$PDT_LIB:$PERL5LIB"

# vim. We may want to use a destinct editor. 
# this gives us the opportunity to define it. 

export PDT_EDITOR=`which vim`
export EDITOR=$PDT_EDITOR

### ONCD  (terminal title setter) 

# rxvt-unicode, and potentially other terminals can 
# have their title lines reconfigured with shell 
# escapes. The program "oncd" is used to set this  
# line. By default it sets directory names on localhost, 
# and if configured properly uses a user@host/dir 
# format when it detects a remote shell. It also 
# takes set strings on the CLI. So we use it with 
# pdt to set class names when editing with vimod. 
# 
# if you are getting weird oncd errors, or flaky 
# terminal behavior turn this off by setting 
# PDT_USEONCD to 0. Remember to edit it below 
# the DATA line in the setpdtrc program, not in 
# the text file, in order to get it to persist. 

export PDT_USEONCD=1

if [ $PDT_USEONCD == 1 ]
then 
export PROMPT_COMMAND=$PDT_BIN/oncd 
fi 

# these aliases allow you to cd to the currently 
# vectored bin and lib directories

alias pdtlib='eval `$PDT_BIN/cdpdtlib`' 
alias pdtbin='eval `$PDT_BIN/cdpdtbin`' 


