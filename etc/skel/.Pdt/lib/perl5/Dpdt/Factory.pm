package Dpdt::Factory;    # EXPORTONLY (:F a)

use Pdt::O qw(:all);
our @ISA = qw(Pdt::O);

use Dpdt::Clock;

use strict;

sub new { # bootstrap and register autolithic objects
   my $class = shift;
   my ( $self, $start ) = AUTOLITH($class);
   my $object;            # que-tainer
   if ($start) {

      $object = Dpdt::Clock->newdpdt(@_);

      $self->cbmap();
   }
   $object = undef;
   return ($self);
}

### CALLBACK

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'clock'} = sub { shift; return $self->clock(@_); };

   return ( $self->{'cbmap'} );
}

### COLLATION

# objects can import handles of other objects
# as locally defined properties

sub cbcollate { # collate one api into properties of another.
   my $self      = shift;
   my $requestor = shift;
   my $property  = shift;

   return undef unless defined $requestor;
   return undef unless length($property);

   # a class from a different API would like to see if there
   # are equivolently named objects in this API, and if so
   # may it have one written into itself with the property
   # name here provided?

   my $rclass = ( ref($requestor) );
   my @rtok   = split( '::', $rclass );
   my $ltok   = pop @rtok;
   $ltok =~ tr/A-Z/a-z/;
   return undef unless length($ltok);

   if ( ref( $self->{'cbmap'}->{$ltok} ) eq 'CODE' ) {
      my $thiscode = $self->{'cbmap'}->{$ltok};
      $requestor->{$property} = &$thiscode(@_);
   }

   return undef;
}

### ACCESSOR

sub clock { my $self = shift; return ( Dpdt::Clock->newdpdt(@_) ); }

### API

# Note: API's can be cascaded with the glue primitve :P g

sub api { # handle to the whole API recast as the root class
   my $self = shift;
   my %O;
   $O{'factory'} = $self;
   $O{'__API__'} = 1;

   $O{'clock'} = $self->clock();

   return ( \%O );
}

1;

