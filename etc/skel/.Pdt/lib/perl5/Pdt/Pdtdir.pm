package Pdt::Pdtdir;

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__
# NOTE: this directory tree is defined in Pdt::Pdtdir
# it is first letter unique for a reason. Save yourself
# some work, and keep it that way. 

Audio				# Audio tracks
Business			# Business related documents
Composition		# non-plaintext documents. 
Data				# Databases, spreadsheets. 
Scm				# Local SCM Integrated Code
Handling			# S&H documents
Install        # Installation Dependencies
Model				# Cad/Cam or other theoretical modeling.
Resource			# Supporting Downloads from the public Internet
Git				# Staging Area For Publish Image (github, or other) 

Periodical_Pub	# published media destined for non-digital format
Exe_Pub			# published executables

Photo				# Photo Frame Art
Photo/MISC		# Nonstandard Resolutions
Photo/VGA		# Standard Resolutions
Photo/480P		
Photo/720P
Photo/1080P		
Photo/1600x900		

Video				# Video recordings.
Video/Blender	# Blender Project Files
Video/MISC		# Nonstandard Resolutions 
Video/VGA		# Standard Resolutions 
Video/480P
Video/720P
Video/1080P
Video/1600x900		

WWW_Pub			# published web documents 
