package Pdt::Help::Setpdtrc;
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

### PERL DEVELOPMENT TEMPLATES 

setpdtrc: Manage environment variables (vectors)
file and directories related to PDT. 

Note: the program "project" provides only the least 
dangerous functions of setpdtrc. It is recommended 
that "project" be used on the CLI, and setpdtrc 
be used in batch processing only. 

setpdtrc manages two files: .pdtrc and .pdtdir
.pdtrc is rewritten every time you change from 
one project to another. Environment variables 
from .pdtrc are imported into all utilities 
in the PDT suite. 

$HOME/.pdtrc and $HOME/.pdtdir are created from 
templates. They are found at: Pdt::Pdtrc and 
Pdt::Pdtdir respectively. 

### INSTALL

	setpdtrc -i # make the initial write of .pdtrc and .pdtdir, 
					# for set them back to their defaults.  

### CREATE NEW PROJECTS

	setpdtrc -p <Projectname> -d  

This will create the project directory <Projectname>, and build 
the subdirectory tree defined in .pdtdir

### USING WITH GITHUB (or other git-able repo) 

	# First: 

	setpdtrc -p <Projectname> -d

	# Second: 

	you must to go to the master host (github.com) and create 
	your repository.  It must have EXACTLY the same name as your 
	ProjectName. 

	Third:  

	clone the project

	cd to /<ProjectRoot>/<ProjectName>/Git 
	git clone https://github.com/<username>/<ProjectName>

	Fourth: 

	tell pdt about your project settings: 

	setpdtrc -g <Projectname>

	Fifth: 

	Edit a file. Then do an add,commit,push with

	project -u | setpdtrc -u 

### DAY TO DAY USAGE

	project					# show the currently selected project 
	project <Myproject>	# will set the active project to Myproject (this wraps setpdtrc -p)

	viexec <myprogram> [linenumber] 	(edit the executble) 
	vimod <Example::Class>	(edit class by classname (not filename))

	project -u 				# does a git add,commit,push in the publish directory

### WHAT IT DOES

	 vim /<ProjectRoot><ActiveProject>/Git/<ActiveProject>/bin/<myprogram> 
	 perltidy /<ProjectRoot><ActiveProject>/Git/<ActiveProject>/bin/<myprogram> 
	 hideinplace /<ProjectRoot><ActiveProject>/Git/<ActiveProject>/bin/<myprogram>
	 versioninplace /<ProjectRoot><ActiveProject>/Git/<ActiveProject>/bin/<myprogram>
	 git add * /<ProjectRoot>/<Myproject>/<$PDT_GIT_DIR>
	 git commit /<ProjectRoot>/<Myproject>/<$PDT_GIT_DIR>
	 git push /<ProjectRoot>/<Myproject>/<$PDT_GIT_DIR>

### SETUP NOTES

"viexec" and "vimod" edit files in the Scm/bin and Scm/lib directories. "project" 
copies files from the Git directory to a foreign git repo. Typically symlinking 
Git/bin to Scm/bin and Git/lib to Scm/lib is how you get your code published. 
The other directories exist for manuals, datasets, support materials etc. 

Example: 

cd <Project>/Git 
ln -s ../Scm/bin bin 
ln -s ../Scm/lib lib 

Note that Pdt was written to work specifically with FvwmSkel, which is project 
centric. If you are using FvwmSkel all of libreoffice will automatically start 
in the appropriate project directories, and will revector to new projects when 
you switch between one project and the next. (using "project") Because of 
this you can just use the same symlink technique to bind documentation and 
other content into your distros.   

