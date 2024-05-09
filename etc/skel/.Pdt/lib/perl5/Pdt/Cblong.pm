package Pdt::Cblong;

# #
my $VERSION = '2018-04-13.07-03-59.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

1;

__DATA__ 
# cblong: designate variables with multiline input

sub cblong { # identify template fields that require multiline input
   my $self = shift ; 
	my @lv = qw(<TMPL_VAR NAME=lc_field_list>) ;
	return @lv ; 
}

