package Pdt::Cbenv;

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
# cbenv: insert environment variables into templates without asking questions.

sub cbenv { # Map uppercase ENV variables to lowercase template variables 
   my $self = shift ; 
	my @ev = qw(<TMPL_VAR NAME=uc_environment_variable_list>) ;
	return @ev ; 
}

