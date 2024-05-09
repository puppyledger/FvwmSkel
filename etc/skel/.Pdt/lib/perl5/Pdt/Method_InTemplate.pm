package Pdt::Method_InTemplate;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

__DATA__
sub <TMPL_VAR NAME=a_method_name>  {    # question dialog
   my $self = shift;
   my $R    = <<"MYDOCUMENT";
HERE
MYDOCUMENT
   return $R;
}

sub _<TMPL_VAR NAME=a_method_name> {    # content processing
   my $self   = shift;
   my $letter = shift;
   my %fpairs = @_;

	my $r ; 

   return $r;
}
