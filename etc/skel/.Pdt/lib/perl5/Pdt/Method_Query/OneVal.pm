package Pdt::Method_Query::OneVal;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: DBI method for returning one value

__DATA__
   my $self = shift;

   $self->{'_<TMPL_VAR NAME=a_methodname>'}->execute(@_);
   my @row = $self->{'_<TMPL_VAR NAME=a_methodname>'}->fetchrow_array( [0] );
	return shift(@row) ; 
