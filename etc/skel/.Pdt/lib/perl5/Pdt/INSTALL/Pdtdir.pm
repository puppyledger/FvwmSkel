package Pdt::INSTALL::Pdtdir;
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
Audio				# Audio tracks
Composition		# non-plaintext documents. 
Data				# Databases, spreadsheets. 
Git				# SCM Integrated Code
Model				# Cad/Cam and/or theoretical modeling.

Still				# Still Frame Art
Still/VGA		# Various Frame Sizes
Still/480P		
Still/720P
Still/1080P		

Video				# Video recordings.
Video/Blender	# Blender Start Files
Video/VGA		# Various resolutions. 
Video/480P
Video/720P
Video/1080P
