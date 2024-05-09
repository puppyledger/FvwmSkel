package Pdt::Method_Here;

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

sub uc_name { # direct call from method_here
	my $self = shift ; 
	my $n = shift  ; 
	my $u = $n ; 
	$u =~ tr/a-z/A-Z/; 
	return ($u)
}

1;

__DATA__ 
sub <TMPL_VAR NAME=method_name> { # 
my $self = shift ;
my $R = <<"<TMPL_VAR NAME=uc_name>";

<TMPL_VAR NAME=uc_name>
return $R;
}

