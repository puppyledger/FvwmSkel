package Pdt::Method_Query::OneHash;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: DBI method for returning one hash

__DATA__
sub <TMPL_VAR NAME=a_methodname> { 
   my $self = shift;
   return($self->{'_<TMPL_VAR NAME=a_methodname>'}->execute(@_));
}
