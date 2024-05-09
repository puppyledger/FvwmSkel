package Pdt::Cbprepare;

# #
my $VERSION = '2018-04-13.07-03-59.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# this class is used to bulk load prepared queries in a Query based
# class.

__DATA__ 
sub <TMPL_VAR NAME=execname> { # (:C <TMPL_VAR NAME=execname>) 
	my $self = shift;

	# bulk load prepare statements 

	<TMPL_VAR NAME=mapstatement>

	return 1 ; 
}
