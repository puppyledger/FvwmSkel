FvwmSkel: Comprehensive user environment for project oriented multi-user *nix 
environments. Install to /etc/skel  

Summary: 

FvwmSkel is a compendium of configurations for the many different systems that 
make up a complete X user environment. This includes Fvwm2, wrappers for 
common user applications (provides custom environmental controls), "rc" files 
for many common programs, open source resources like icons, sounds and 
backgrounds etc. etc. 

FvwmSkel is "project centric", which is different from most environments which 
are "user centric". What this means is that default locations for file saves 
and downloads are vectored at shared project directories rather than a personal 
directory. This is intended to allow a multiuser environment such as a 
thin-client or multi-seat coniguration to work cleanly and quickly together. 

FvwmSkel is a "sloppyfocus" based configuration, which makes using small screen 
real estate easier. (works well from a laptop) It also has a modal desktop 
control: the 9-key number pad directly autofocuses on the corresponding virtual 
desktop. If you need to use the 9-key for something else, "numlock" turns this 
off. Alt-Tab moves the cursor to the next window and raises it. So this works 
like normal alt-tab cycling even though focus sloppy.  This setup makes use of 
the mouse rare, since you can focus any desktop and window with just a few 
keystrokes. 

FvwmSkel also includes project management tools in the form of the command 
"project", and "setpdtrc", which are used to provide the above mentioned 
project oriented file-save vectoring, but are able to do much much more. 
FvwmSkel integrates with Bash::Sugar and Pdt (Perl Development Templates)  
which provides a templating system that integrates directly with VIM (and 
potentially other editors). So you get a code templating system as well. 

Origin: 

FvwmSkel is a collection of more than a decades worth of one-off hacks that 
have been used to solve various problems. Only recently has any effort been 
made to turn it into something reasonably uniform. Much of the code that 
is in a "not-yet-rafactored" state. Consider this project alpha. 

Note that Fvwm2 is positively ancient itself. It uses a unique 
configuration protocol (predating XML and JASON) and it's single-threaded. 
This makes working with it "hackerish". This is good if you want to just 
want to bodge up something custom. It is bad for redistritability since 
so there are many many static configuration elements. 

Documentation: 

Sparse, in a word. Most scripts and applications have source comments that 
describe what individual things do. FvwmSkel was not originally intended to 
be distributed, but I would really like to have some help with it. So I am 
trying to clean it up and make it a public repo.   Everything fancy is 
FvwmSkel is written in perl or bash, so you can just look at the files to 
see what they are "supposed" to do. Most perl tools have a -h option for 
a help file. 

Install is not automatic: 

1. Download and put in /etc/skel. 

2. edit all the .xinitrc paths

3. Look in /etc/skel/.fvwm/start and /etc/skel/.fvwm/macro 

4. Look at the paths in these files and update and install as appropriate.  

5. note any programs that have wrappers that are/aren't installed. Either 
   install them, or "chmod 000" the associated wrapper to take it out of 
	the menu. 

6. symlink all the dot files in /etc/skel into  directory. 

	Note: if you start getting terminal errors with every return, it is 
	probably because of the program "oncd", which runs with every cairrage 
	return. Check its path. This proggy makes nice terminal headings. 

	If something is busted, comment, (I don't guarantee I will fix it right
	away) or patch it and send me the patch. 

Status: 

This version is the result of being recovered after being abandoned for 
a while. There was a crash, and it was already hacky and I didn't want 
to deal with all the dangling code maintenance to get it back online
on a new platform.  

Now I am getting around to it, but that means that there is still a lot
broken. 

FvwmSkel is currently being used and maintained on VOID linux, which is 
a very good non-systemd based linux distribution, which may (or may not) 
have a file system layout complementory to what you are using.  

Refactoring some of the core code broke a lot of things. Some are broken 
because paths still need to be updated. Some are genuinely just broke. 
Some are cruft and shouldn't even be here. 

Audio integration (pooks and bleeps) aren't currently working. Fancy icon 
bindings aren't currently working out of the box.  There are 
many tools here that aren't documented, including stuff for doing 
progressive backups, and connecting projects to external github 
type services. There was an ffmpeg wrapper for doing video and audio 
capture directly from window title bars. I have to find it in my 
backups and add it still. 

For the moment this is a decent Fvwm config with a lot of stuff working
and a lot of stuff not working. Please take a look and send patches 
if you fix anything. (there is a lot to fix) Adding start wrappers 
is trivial, and amounts to copying a wrapper file in: 
(/etc/skel/.fvwm/start) to an appropriate name, chmod'ing it, and 
changing the target inside of the werapper file. Then restart Fvwm. 
(some menus are autogenerated, eventually most if not all will be. 

Terminals: 
	URXVT: Urxvt windows have their titles updated with 
	the current path or edited file (if using vim),  
	and if using SSH, that will be preceded by the remote  
	host or IP address. (it did work that way, not sure now) 
	This is accomplished with the proggy "oncd". If you are 
	getting "not found errors" on the terminal, find this 
	and fix its path. It works by throwing control 
	characters.  

	URXVT is ancient, and there are likely better options. 
	YMMV

	Minicom

	There are still a lot of ancient switches and routers 
	out there, and this will get you a working console on 
	them. It should be already configured for a USB serial 
	port adapter. 

Key bindings: 
	Windows key is used for iconification deiconification

	F12 and Alt-F12 are bound to the Vi key sequence for 
	inserting and deleting comment lines. 

Title bar bindings: 
	uparrow: shade,unshade|maximize,unmaximize (L|R mouse clicks)
	right dot: <none>,close window

	Audio Video from Titlebar: 
	Circle: ffmeg record this window (broken)
	Square: ffmeg stop recording window (broken)
	triangle: ffmpeg play back last recording (broken)

	note: there is a background called "resolution" which 
	I made that has squares defining exact standard 
	resolutions if you use this background and the 
	appropriate recording resolution, just fit your 
	window in the correct gray box and it will be 
	properly sized. 
	
That is about all I remember at present. As this gets 
closer to being fully restored I will add updates. 

