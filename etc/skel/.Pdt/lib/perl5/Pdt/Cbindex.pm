package Pdt::Cbindex;

# #
my $VERSION = '2018-04-13.07-03-59.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

1;

# This template is used to bulk load code callbacks for a variety of
# autolith type classes.

__DATA__ 
sub <TMPL_VAR NAME=execname> { # (:C <TMPL_VAR NAME=execname>)
	my $self = shift;
	my $lookup = shift; 

   # callback map, generally run at constructor time only.
   # The <TMPL_VAR NAME=execname> program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

	my $<TMPL_VAR NAME=mapname> = {
	<TMPL_VAR NAME=mapstatement>
	} ; 

	return ($<TMPL_VAR NAME=mapname>->{$lookup}) ;
}
