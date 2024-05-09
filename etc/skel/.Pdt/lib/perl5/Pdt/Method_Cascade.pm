package Pdt::Method_Cascade;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__
sub <TMPL_VAR NAME=b_cascade_method_name> { return(&<TMPL_VAR NAME=a_localized_method_name>(@_)) ; }
