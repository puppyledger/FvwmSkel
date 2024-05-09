package Pdt::Method_Query::OneCol;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: DBI method for returning a reference to an array containing one column

__DATA__
   my $self = shift;
	my @col ; 

   $self->{'_<TMPL_VAR NAME=a_methodname>'}->execute(@_);
   my @row = $self->{'_<TMPL_VAR NAME=a_methodname>'}->fetchall_array( [0] );

	foreach(@row) { push @col, shift @$_ ; } 

	return (\@col) ;
