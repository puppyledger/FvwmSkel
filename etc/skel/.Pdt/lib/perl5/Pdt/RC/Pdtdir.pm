package Pdt::RC::Pdtdir;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: .pdtdir contains directories structures to build when running setpdtrc

__DATA__
# setpdtrc will automatically build these directories when called with -d
Audio				# Audio tracks
Composition		# Product Specs, Marketing Copy
Data				# Databases, spreadsheets. 
Git				# SCM Integrated Code
Video				# Video recordings.
Video/VGA		# Various resolutions. 
Video/480P
Video/720P
Video/1080P
Model				# Cad/Cam and/or theoretical modeling.
