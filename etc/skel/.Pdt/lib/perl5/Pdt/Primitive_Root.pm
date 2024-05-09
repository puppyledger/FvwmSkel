package Pdt::Primitive_Root;

my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# template for a standardized API root class

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; # (P: r) 

#: <TMPL_VAR NAME=brief_class_description>

use <TMPL_VAR NAME=c_foundation_class> ;
use <TMPL_VAR NAME=d_api_full_factory_class> ; 
our @ISA = qw(<TMPL_VAR NAME=c_foundation_class>) ; 

use strict ; 

our $__API__ = undef ;

$::_DEBUGAUTOLOAD = 0 ; # trace bad function calls that puke in Pdt::O 

### CONSTRUCTORS

# calling new() on a root class returns the factory for all of its objects. 

sub new { # a constructor for outside calls
	shift ; 
	return ($<TMPL_VAR NAME=a_fullpackagename>::__API__) if (defined $<TMPL_VAR NAME=a_fullpackagename>::__API__) ;
	my $F = <TMPL_VAR NAME=d_api_full_factory_class>->new(@_) ; 
	my $A = $F->api() ; 
	bless $A, "<TMPL_VAR NAME=a_fullpackagename>" ;
	$<TMPL_VAR NAME=a_fullpackagename>::__API__ = $A ; # store for setgets
	return $A ;
} 

# get for the whole API handle. 

sub <TMPL_VAR NAME=d_common_constructor>api { # a constructor for inside calls 
	return (<TMPL_VAR NAME=a_fullpackagename>::__API__) ; 
}

### SETGET (:M apiget <TMPL_VAR NAME=a_fullpackagename> <TMPL_VAR NAME=d_api_full_factory_class>) # autogen accessors

1 ; 
