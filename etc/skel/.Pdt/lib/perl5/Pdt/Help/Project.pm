package Pdt::Help::Project;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats:

__DATA__
					project: 

			A safety wrapper for setpdtrc.  

"setpdtrc" is responsible for managing the .pdtrc, and the 
.pdtdir file and creating new project frameworks. 

"project" is a safety wrapper for the "setpdtrc" program.
It's purpose is to provide a limited command set to prevent 
accidental damage.

If you want to add features, it might be better for fork "project" 
rather than "setpdtrc", as setpdtrc is unlikely to be code complete 
for some time. 

The simplified command set is: 

project              # show the currently selected pdt project 

project -n           # create a new project with subdirectories 
                     # and set  an initial git configuration. 

project <Myproject>  # will set the active pdt project to Myproject 
                     # If no project matches it will list all projects
                     # This just wraps setpdtrc -p

project -l           # list the current projects

project -u           # does a git add,commit,push (this wraps setpdtrc -u) 

If you are setting up new projects, or connecting perl pdt 
up to github, see: setpdtrc -h

