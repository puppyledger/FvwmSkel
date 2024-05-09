package Pdt::Method_Wrapper;

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
sub <TMPL_VAR NAME=method_name> { my $self = shift ;  return($self->{'<TMPL_VAR NAME=property_name>'}-><TMPL_VAR NAME=method_name>(@_)) ; }
