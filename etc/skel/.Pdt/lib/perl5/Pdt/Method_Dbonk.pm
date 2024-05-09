package Pdt::Method_Dbonk;

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
sub <TMPL_VAR NAME=method_name> { # (:M dbonk)
   my $self = shift ;  
	use Pdt::Bonk qw(:all) ; 
	dbonk "--- <TMPL_VAR NAME=method_name> undefined setget ---" ; 
   $self->{'<TMPL_VAR NAME=method_name>'} = $_[0] if defined $_[0] ;
   return $self->{'<TMPL_VAR NAME=method_name>'} ;
}
