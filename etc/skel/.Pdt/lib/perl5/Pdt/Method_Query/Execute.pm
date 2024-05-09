package Pdt::Method_Query::Execute;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Execute Only DBI method

__DATA__
   return($self->{'_<TMPL_VAR NAME=a_methodname>'}->execute(@_));
