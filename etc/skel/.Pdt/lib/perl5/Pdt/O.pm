package Pdt::O;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

#: Object class with autoload set/get methods, autodispatch,
#: and object registration. Monolithic objects are called
#: autoliths (objects that will return the same object
#: no matter how many times you call new()) Normal
#: objects are called pluroliths. The new() method should
#: bless using the imported functions:
#:
#: ($self, $start) = PLUROLITH($class) |
#:  ($self, $start) = AUTOLITH($class)
#:
#: Dispatch at constructor time is handled by three
#: methods:
#:
#:	$self->AUTOPOPULATE(@_) | $self->AUTOMAP(@_) | $self->AUTODISPATCH
#:
#:  AUTOPOPULATE is a hash to property function, without methods.
#:
#:  AUTOMAP searches out a callback in $self->{'cbmap'}
#:     and dispatches the hash value to it, then falls
#:     back to setting a property  if no method is
#: 	 available.
#:
#: AUTODISPATCH looks for code references matching the
#: 	key in $self, and run them.
#:
#: Construction and population are considered two steps,
#: and should happen independently. This allows new()
#: to detect $start, and know if this is the first run.
#:
#: The main namespace: $::_AUTOLITH, is considered reserved,
#: and is only used by Pdt::O derived modules.

my $VERSION = '3.7';

use Exporter;        #
use Data::Dumper;    #

our @EXPORT = qw(AUTOLITH AUTOQUE PLUROLITH PLUROQUE DUMPREGISTRY COLLAPSE AUTOLOAD);
our %EXPORT_TAGS = ( 'all' => [ qw(AUTOLITH AUTOQUE PLUROLITH PLUROQUE DUMPREGISTRY COLLAPSE AUTOLOAD) ] );

our @ISA = qw(Exporter);

use strict;

### PROTOTYPE CONSTRUCTOR
#
# sub new {            # REDEFINE ME
#   my $class = shift;
#
#   # Do this if you want one object, regardless of how many times you call new()
#
#   my ( $self, $start ) = AUTOLITH($class);    # registered objects
#
#   # Do this if you want a new object every time you call new
#
#   my ( $self, $start ) = PLUROLITH($class);    # unregistered objects
#
#   # do this if you want a property that blanks on every new()
#
#   $self->{'foo'} = undef;                      #
#
#   # do this to autoset constructor arguments into properties
#
#   $self->AUTOPOPULATE(@_);
#
#   if ($start) {
#
#      # stuff that only runs at startup goes here, which typically
#      # includes setting up callback maps.
#
#      $self->cbmap();    # setup our callback maps.
#
#   } else {
#
#      # since we can get a handle with new(), as an autolith we
#      # can put stuff here that only runs AFTER the first time
#      # new is called.
#
#      $self->secondnewonly();
#
#   }
#
#   # if we want to autorun cosntructor arguments we can do this
#   # insteadl of autopopulating. This will hook into cbmap
#
#   $self->AUTOMAP(@_);
#
#   # statics and empty stacks can be defined here.
#
#   $self->{'foo'} = [];
#   $self->{'pi'}  = 3.141592;
#
#   return $self;
# }
#

### EXPORTS

sub DUMPREGISTRY { # warn all autolithic objects
   warn Dumper($::_AUTOLITH);
}

sub AUTOLITH { # monolithic (registered) hash object constructor
   my $class = shift;
   $::_AUTOLITH = {} unless ( ref($::_AUTOLITH) eq 'HASH' );    # The registry
   return ( $::_AUTOLITH->{$class}, 0 ) if defined $::_AUTOLITH->{$class};    # return preregistered class
   $::_AUTOLITH->{$class} = bless {}, $class;                                 # make the registered class
   return ( $::_AUTOLITH->{$class}, 1 );                                      # return newclass and init flag
}

sub PLUROLITH { # pluralistic (unregistered) object constructor
   my $class = shift;
   my $self  = {};
   bless $self, $class;
   return ( $self, 1 );
}

sub AUTOQUE { # monolithic (registered) array object constructor
   my $class = shift;
   $::_AUTOLITH = {} unless ( ref($::_AUTOLITH) eq 'HASH' );                  # The registry
   return ( $::_AUTOLITH->{$class}, 0 ) if defined $::_AUTOLITH->{$class};    # return preregistered class
   $::_AUTOLITH->{$class} = bless [], $class;                                 # make the registered class
   return ( $::_AUTOLITH->{$class}, 1 );                                      # return newclass and init flag
}

sub PLUROQUE { # plurolistic (unregistered) array object constructor
   my $class = shift;
   my $self  = [];
   bless $self, $class;
   return ( $self, 1 );
}

sub COLLAPSE { # delete an autolith from the registry (does not neccessarily delete all external references)
   my $class = shift;
   $::_AUTOLITH->{$class} = undef;
}

# this AUTOLOAD should be avoided from a performance perspective.
# It is primarly here to catch and warn on dangling methods, and
# help with prototyping if your doing something experimental.

sub AUTOLOAD { # automatic set/get method
   my $self = shift;
   our $AUTOLOAD;    # what we spoofing

   my @tree = split( /\:\:/, $AUTOLOAD );

   my $functioname = pop @tree;
   my $namespace   = pop @tree;

   return undef if $functioname eq "DESTROY";     # Destruction requires no action
   return undef if $functioname eq $namespace;    # Avoid recursion

   warn "AUTOLOAD: namespace, functioname: ", $namespace, ",", $functioname if $::_DEBUGAUTOLOAD;

   # simple set/get, true if set, value if exist, undef if neither

   if ( defined $_[ 0 ] ) {                       # passed variables interpolate

      # Bad function calls sometimes dump here unexpectedly.
      # so we try and warn about it helpfully. While Pdt
      # can autoload, it generally shouldn't since autoload
      # is slow.

      eval('$self->{$functioname} = $_[ 0 ];');

      if ($@) {    #
         warn $@;
         warn "bad function call: $self $functioname";
      }

      return 1;
   }

   return $self->{$functioname};
}

### INHERIT

sub AUTOPOPULATE { # covert a hash into sets
   my $self = shift;
   my %args = @_;

   foreach ( keys(%args) ) {
      $self->{$_} = delete $args{$_};
   }

   return 1;
}

sub AUTOMAP { # dump a hash into functions defined in the callback map
   my $self = shift;

   return undef unless ( scalar(@_) && defined $self->{'cbmap'} );

   my %this = @_;

   # this warning should detect collisions which can happen during replication

   # bonk "PDT", "AUTOMAP detected callbacks:\n\t", join "\n\t", ( keys( %{ $self->{'cbmap'} } ) );

   foreach my $k ( keys(%this) ) {

      # first we check for the method and run it if possible

      if ( ref( $self->{'cbmap'}->{$k} ) eq 'CODE' ) {

         my $callback = $self->{'cbmap'}->{$k};
         &$callback( $self, $this{$k} );
         delete( $this{$k} );

      } else {

         # if not do a simple set.

         $self->{$k} = delete( $this{$k} );

      }

   }

   return $self;
}

sub AUTODISPATCH { # convert a hash embedded code calls, OR sets
   my $self = shift;
   my %args = @_;

   # This is used in Pdt::T, and so cannot be deleted.

   foreach ( keys(%args) ) {
      if ( ref( $self->{$_} ) eq 'CODE' ) {
         $self->{$_}( $args{$_} );
         delete( $args{$_} );
      } else {
         $self->{$_} = delete( $args{$_} );
      }
   }

   return 1;
}

# occasionally a Pdt::O is built as an array, rather than
# a hash. AUTOMERGE provides overlay interpolation for
# thoses cases.

sub AUTOMERGE { # overlay defined values into an array object.
   my $self = shift;    # an ARRAY ref.
   my $n    = 0;
   foreach (@_) {
      if ( defined($_) ) {
         $self->[ $n ] = $_;
      }
      $n++;
   }
   return 1;
}

sub DUMPSELF { # warn self
   my $self = shift;
   warn Dumper($self);
}

sub cbexist { # get a callback if it exists
   my $self = shift;

   if ( ref( $self->{'cbmap'} ) eq 'HASH' ) {    #
      if ( ref( $self->{'cbmap'}->{ $_[ 0 ] } ) eq 'CODE' ) {    #
         return ( $self->{'cbmap'}->{ $_[ 0 ] } );
      }
   }

   return undef;
}

sub cbrun { # ambivilant run attempt
   my $self = shift;

   if ( ref( $self->{'cbmap'} ) eq 'HASH' ) {                    #
      if ( ref( $self->{'cbmap'}->{ $_[ 0 ] } ) eq 'CODE' ) {    #
         my $cbname = shift;
         return ( &{ $self->{'cbmap'}->{$cbname} }(@_) );
      }
   }

   return undef;
}

sub swrite { # from the camel book (this is required for Pdt::Method_Format)
   my $self   = shift;
   my $format = shift;
   $^A = "";
   formline( $format, @_ );
   return $^A;
}

1;
