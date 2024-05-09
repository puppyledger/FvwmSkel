package Pdt::Term::Form;    # (P: o)

#: character IO for Pdt Form

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);    # OS specific C symbols or file handling.
use POSIX qw(:errno_h);                      # prens required to constrain imported namespace

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Pdt::Form::Event qw(:all);               # gives us newevent()
use Pdt::Term;

use Term::ReadKey;                           # Provides ReadMode Setting
use Term::Screen;

our @ISA = qw(Term::Screen Pdt::Term);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Term::Form->newterm(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newterm {
   my $class = shift;
   my %OPT   = @_;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # map our exportable functions

   if ($start) {

      # We construct as an autolith to get the registry functionality,
      # then we run the superclass Term::Screen->new() to get initial
      # terminal settings, then we bless back to our local class.

      ReadMode 4;    # Term::ReadKey set nonblock raw
      my $self = Term::Screen->new();
      bless $self, $class;

      $self->cbmap();    # create a method map

      $self->{'FIELDBUF'} = [];    # character array of the currently focused field buffer
      $self->{'fieldptr'} = 0;     # pointer to the cursor offset in the field

   } else {

      # runtime completeness checks

   }

   # stack cleanup

   return $self;
}

### CALLBACKS

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'condensebuf'} = sub { shift; return $self->condensebuf(@_); };
   $self->{'cbmap'}->{'expandbuf'}   = sub { shift; return $self->expandbuf(@_); };
   $self->{'cbmap'}->{'fieldptr'}    = sub { shift; return $self->fieldptr(@_); };
   $self->{'cbmap'}->{'keyevent'}    = sub { shift; return $self->keyevent(@_); };
   $self->{'cbmap'}->{'resetterm'}   = sub { shift; return $self->resetterm(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

#### CURSOR

# When we are typing the cursor is moving L/R, and we are shifting a ptr in
# relation to the cursor so that the edits write to the field buffer as well
# as the screen, and can then be later condensed back into the actual field.

sub fieldptr {    # set/get
   my $self = shift;

   # this handles both a scalar, and a reference to a scalar, so it can be hooked
   # by a widgets own field pointer (to create persistence) if neccessary.

   if ( ref( $_[ 0 ] ) eq 'REF' ) {
      $self->{'fieldptr'} = ${ $_[ 0 ] };
   } elsif ( defined $_[ 0 ] ) {
      $self->{'fieldptr'} = $_[ 0 ];
   }

   return $self->{'fieldptr'};
}

#### BUFFER HANDLING

# when a field is focused, we expand the content of it into
# a character bufer and condense back into the value when
# unfocused. These functions provide that capacity.

sub expandbuf {    # expand the text in the editable field, into an array of characters for indevidual placement
   my $self   = shift;
   my $bufref = shift;    # scalar reference to the actual template field.

   bonk "TERM", "undefined buffer" unless ( ref($bufref) eq 'REF' );

   unless ( length($$bufref) ) {    #
      $self->{'FIELDBUF'} = [];
   } else {
      $self->{'FIELDBUF'} = [];
      @{ $$self->{'FIELDBUF'} } = split( '', $$bufref );
   }

   scalar( @{ $$self->{'FIELDBUF'} } );
}

sub condensebuf {                   # condense the array of characters back into the actual field value
   my $self   = shift;
   my $bufref = shift;
   $$bufref = join '', @{ $$self->{'FIELDBUF'} };
   return length($$bufref);
}

#### INITIAL KEY DETECTION

sub keyevent {                      # We return the keyvalue, not the character.
   my $k = ReadKey(-1);
   my $ka;

   if ( length($k) ) {
      $ka = ord($k);
      return ($ka);
   }

   return ();
}

#### EXIT

sub resetterm {    # reset the terminal settings before exit
   my $self = shift;
   $self->clrscr();
   ReadMode 0;     # Reset tty mode before exiting
}

1;
