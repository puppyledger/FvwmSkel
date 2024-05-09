package Pdt::Method_StackSuper;

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

# OK. This is completely redundant if your inheriting. But
# sometimes you want to block fill code without being
# sure whether inheritance is the best way to go. It
# is easier to comment code that has working dispatch
# and verify working inheritance, than it is to
# troubleshoot an inherited function that you may or
# may not remember.

__DATA__
sub <TMPL_VAR NAME=method_name> { # (M: stacksuper)
   my $self = shift ;  
   return ( $self->SUPER::<TMPL_VAR NAME=method_name>(@_) );
}
