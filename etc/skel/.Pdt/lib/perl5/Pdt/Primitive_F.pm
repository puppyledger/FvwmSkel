package Pdt::Primitive_F;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# Factory for autolith based classes. This class initializes all of
# the objects in a directory and provides accessor methods for those
# classes. This is accessed with :F a

__DATA__ 
package <TMPL_VAR NAME=factoryclassname> ; # EXPORTONLY (:F a)

use Pdt::O qw(:all) ;
our @ISA = qw(Pdt::O) ; 

<TMPL_VAR NAME=usestatements>

use strict;

sub new { # bootstrap and register autolithic objects
	my $class = shift ;
	my ($self, $start) = AUTOLITH($class) ; 
	my $object ; # que-tainer
	if ($start) {<TMPL_VAR NAME=initstatements>  
	}
	$object = undef ;  
   return ($self)  ; 
}

<TMPL_VAR NAME=accessorstatements>  

sub allobject { # get all of the objects as a keyed hash
	my $self = shift ; 
	my %O ; <TMPL_VAR NAME=allobjectstatements>  
	return %O ; 
}

1; 
