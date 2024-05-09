package Pdt::Factory_A;

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
	$self->{'factory'} = $self ; 
	if ($start) {<TMPL_VAR NAME=initstatements>  
		$self->cbmap() ; 
	}
   return ($self)  ; 
}

### CALLBACK 

<TMPL_VAR NAME=callbackstatements>  

### ACCESSOR

<TMPL_VAR NAME=accessorstatements>  

### API: All of these return the factory class reblessed to the root API class.  
### Only new() will attempt to construct before returning it. 

# $rootclass->new() 
# $rootclass->api() 
# $factoryclass->api()  
# $derivedclass->api() 

sub api { # handle to the whole API recast as the root class
	my $self = shift ; 
	return $<TMPL_VAR NAME=rootclass>::__API__ ; 
}

1; 
