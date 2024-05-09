package Pdt::Method_Setget;

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__

sub <TMPL_VAR NAME=method_name> { # (:M setget)
   my $self = shift ;  
   $self->{'<TMPL_VAR NAME=method_name>'} = $_[0] if (defined $_[0]) ;
   return $self->{'<TMPL_VAR NAME=method_name>'} ;
}
