package Pdt::Method_Query::AllHash;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Template for DBI for a method that returns all rows as an arrayref of hashes

__DATA__
   my $self = shift;
   $self->{'_<TMPL_VAR NAME=a_methodname>'}->execute(@_);
   my $arrayref = $self->{'_<TMPL_VAR NAME=a_methodname>'}->fetchall_arrayref( {} );
   return $arrayref;
