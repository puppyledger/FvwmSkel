package Pdt::Method_KeyAdd;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

__DATA__
	my $<TMPL_VAR NAME=hash_name> = { # (:M keyadd)
	<TMPL_VAR NAME=keyset_entry>	
	} ; 
	<TMPL_VAR NAME=fully_qualified_object>->keyadd(%$<TMPL_VAR NAME=hash_name>) ; 
