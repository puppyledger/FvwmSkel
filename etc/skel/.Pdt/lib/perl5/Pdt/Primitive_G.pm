package Pdt::Primitive_G;

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# Glue classes enable cascading of API classes.

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; # (P: o)

#: <TMPL_VAR NAME=brief_class_description>

use Pdt::O qw(:all) ; 
use <TMPL_VAR NAME=c_foreign_root_class_to_glue> ;

use strict ; 

### CONSTRUCTORS

sub new { 
	my $self = shift ; 
	my $F = <TMPL_VAR NAME=c_foreign_root_class_to_glue>->new(@_) ; 
	return ($F->api()) ; 
}

sub <TMPL_VAR NAME=d_local_api_common_constructor_name> { 
	my $self = shift ; 
	my $F = <TMPL_VAR NAME=c_foreign_root_class_to_glue>->new(@_) ; 
	return ($F->api()) ; 
}

1; 
