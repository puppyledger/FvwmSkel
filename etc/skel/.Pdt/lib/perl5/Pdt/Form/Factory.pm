package Pdt::Form::Factory;    # EXPORTONLY (:F p)

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

use Pdt::O qw(:all);
our @ISA = qw(Pdt::O);

use Pdt::Form::Button;
use Pdt::Form::Checkbox;
use Pdt::Form::Entry;
use Pdt::Form::Password;

use strict;

# factories are autolithic, but widgets are plurolistic, so
# none are constructed at startup.

### CONSTRUCTOR

sub new {    # factory is a simple autolith
   my $class = shift;
   my ( $self, $start ) = AUTOLITH($class);
   $self->cbmap() if $start;
   return ($self);
}

sub newwidget {    # construct a plurolith by name
   my $self       = shift;
   my $methodname = shift;

   if ( ref( $self->{'cbmap'}->{$methodname} ) eq 'CODE' ) {
      return ( &{ $self->{'cbmap'}->{$methodname} }( $self, @_ ) );
   }

   return undef;
}

### CALLBACK

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'button'}   = sub { shift; return $self->button(@_); };
   $self->{'cbmap'}->{'checkbox'} = sub { shift; return $self->checkbox(@_); };
   $self->{'cbmap'}->{'entry'}    = sub { shift; return $self->entry(@_); };
   $self->{'cbmap'}->{'password'} = sub { shift; return $self->password(@_); };

   return ( $self->{'cbmap'} );
}

sub cbcollate {    # collate one api into properties of another.
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

sub button   { my $self = shift; return ( Pdt::Form::Button->newwidget(@_) ); }
sub checkbox { my $self = shift; return ( Pdt::Form::Checkbox->newwidget(@_) ); }
sub entry    { my $self = shift; return ( Pdt::Form::Entry->newwidget(@_) ); }
sub password { my $self = shift; return ( Pdt::Form::Password->newwidget(@_) ); }

1;

