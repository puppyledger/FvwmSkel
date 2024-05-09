package Pdt::Factory_P;

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
# classes. This is accessed with

__DATA__ 
package <TMPL_VAR NAME=factoryclassname> ; # EXPORTONLY (:F p)

use Pdt::O qw(:all) ;
our @ISA = qw(Pdt::O) ; 

<TMPL_VAR NAME=usestatements>

use strict;

# factories are autolithic, but widgets are plurolistic, so 
# none are constructed at startup. 

### CONSTRUCTOR

sub new { # factory is a simple autolith
	my $class = shift ;
	my ($self, $start) = AUTOLITH($class) ; 
	$self->cbmap() if $start ; 
   return ($self)  ; 
}

<TMPL_VAR NAME=namedconstructor>
	my $self = shift ; 
	my $methodname = shift ; 

	if (ref($self->{'cbmap'}->{$methodname}) eq 'CODE') {
		return(&{$self->{'cbmap'}->{$methodname}}($self, @_)) ; 
	}

	return undef ; 
}

### CALLBACK 

<TMPL_VAR NAME=callbackstatements>  
sub cbcollate { # collate one api into properties of another.
   my $self = shift ;
   my $requestor = shift ;
   my $property = shift  ;

   return undef unless defined $requestor ;
   return undef unless length($property) ;

   # a class from a different API would like to see if there
   # are equivolently named objects in this API, and if so
   # may it have one written into itself with the property
   # name here provided?

   my $rclass = (ref($requestor)) ;
   my @rtok = split('::',$rclass) ;
   my $ltok = pop @rtok  ;
   $ltok =~ tr/A-Z/a-z/  ;
   return undef unless length($ltok) ;

   if (ref($self->{'cbmap'}->{$ltok}) eq 'CODE') {
      my $thiscode = $self->{'cbmap'}->{$ltok} ; 
      $requestor->{$property} = &$thiscode(@_) ;
   }

   return undef ;
}

### ACCESSOR <TMPL_VAR NAME=accessorstatements>  

1; 
