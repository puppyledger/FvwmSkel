package Pdt::Method_AliasProp;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: a method that writes to a property, not its own. 

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__
sub <TMPL_VAR NAME=method_name> { #: alias <TMPL_VAR NAME=method_name> to <TMPL_VAR NAME=method_target> 
   my $self = shift ;  
   $self->{'<TMPL_VAR NAME=method_target>'} = $_[0] if defined $_[0] ;
   return $self->{'<TMPL_VAR NAME=method_target>'} ;
}

