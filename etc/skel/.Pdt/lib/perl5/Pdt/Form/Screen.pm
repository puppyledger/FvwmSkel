package Pdt::Form::Screen;    # (P: o)

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Term::Screen does not take inheritance well, so we
#: wrap it here and add features

#: This has been moved over from Pdt::Term::Form which is
#: now deprecated, as is any direct calls to Term::Screen.
#: Any advanced terminal features should derive and exist
#: below this class.

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);    # OS specific C symbols or file handling.
use POSIX qw(:errno_h);                      # prens required to constrain imported namespace
use Term::Screen;
use Term::ReadKey;

use Pdt::O qw(:all);
use Pdt::Form::API qw(:all);
use Pdt::Form::Event qw(:all);
use Pdt::Bonk qw(:all);

our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Screen->newscreen(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newscreen {
   my $class = shift;
   my %OPT   = @_;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # map our exportable functions

   if ($start) {

      # We construct as an autolith to get the registry functionality,
      # then we run the superclass Term::Screen->new() to get initial
      # terminal settings, then we bless back to our local class.

      ReadMode 4;    # Term::ReadKey set nonblock raw
      $self->{'TERM'} = Term::Screen->new();

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

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'at'}           = sub { shift; return $self->at(@_); };
   $self->{'cbmap'}->{'bold'}         = sub { shift; return $self->bold(@_); };
   $self->{'cbmap'}->{'clreol'}       = sub { shift; return $self->clreol(@_); };
   $self->{'cbmap'}->{'clreos'}       = sub { shift; return $self->clreos(@_); };
   $self->{'cbmap'}->{'clrscr'}       = sub { shift; return $self->clrscr(@_); };
   $self->{'cbmap'}->{'cols'}         = sub { shift; return $self->cols(@_); };
   $self->{'cbmap'}->{'condensebuf'}  = sub { shift; return $self->condensebuf(@_); };
   $self->{'cbmap'}->{'curinvis'}     = sub { shift; return $self->curinvis(@_); };
   $self->{'cbmap'}->{'curvis'}       = sub { shift; return $self->curvis(@_); };
   $self->{'cbmap'}->{'dc'}           = sub { shift; return $self->dc(@_); };
   $self->{'cbmap'}->{'dc_exists'}    = sub { shift; return $self->dc_exists(@_); };
   $self->{'cbmap'}->{'def_key'}      = sub { shift; return $self->def_key(@_); };
   $self->{'cbmap'}->{'DESTROY'}      = sub { shift; return $self->DESTROY(@_); };
   $self->{'cbmap'}->{'dl'}           = sub { shift; return $self->dl(@_); };
   $self->{'cbmap'}->{'echo'}         = sub { shift; return $self->echo(@_); };
   $self->{'cbmap'}->{'expandbuf'}    = sub { shift; return $self->expandbuf(@_); };
   $self->{'cbmap'}->{'fieldptr'}     = sub { shift; return $self->fieldptr(@_); };
   $self->{'cbmap'}->{'flush_input'}  = sub { shift; return $self->flush_input(@_); };
   $self->{'cbmap'}->{'get_fn_keys'}  = sub { shift; return $self->get_fn_keys(@_); };
   $self->{'cbmap'}->{'getch'}        = sub { shift; return $self->getch(@_); };
   $self->{'cbmap'}->{'ic'}           = sub { shift; return $self->ic(@_); };
   $self->{'cbmap'}->{'ic_exists'}    = sub { shift; return $self->ic_exists(@_); };
   $self->{'cbmap'}->{'il'}           = sub { shift; return $self->il(@_); };
   $self->{'cbmap'}->{'key_pressed'}  = sub { shift; return $self->key_pressed(@_); };
   $self->{'cbmap'}->{'keyevent'}     = sub { shift; return $self->keyevent(@_); };
   $self->{'cbmap'}->{'noecho'}       = sub { shift; return $self->noecho(@_); };
   $self->{'cbmap'}->{'normal'}       = sub { shift; return $self->normal(@_); };
   $self->{'cbmap'}->{'puts'}         = sub { shift; return $self->puts(@_); };
   $self->{'cbmap'}->{'resetandexit'} = sub { shift; return $self->resetandexit(@_); };
   $self->{'cbmap'}->{'resize'}       = sub { shift; return $self->resize(@_); };
   $self->{'cbmap'}->{'reverse'}      = sub { shift; return $self->reverse(@_); };
   $self->{'cbmap'}->{'rows'}         = sub { shift; return $self->rows(@_); };
   $self->{'cbmap'}->{'stuff_input'}  = sub { shift; return $self->stuff_input(@_); };
   $self->{'cbmap'}->{'term'}         = sub { shift; return $self->term(@_); };

   return ( $self->{'cbmap'} );
}

#### FEATURES

sub fieldptr { # set/get
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

sub expandbuf { # expand the text in the editable field, into an array of characters for indevidual placement
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

sub condensebuf { # condense the array of characters back into the actual field value
   my $self   = shift;
   my $bufref = shift;
   $$bufref = join '', @{ $$self->{'FIELDBUF'} };
   return length($$bufref);
}

#### INITIAL KEY DETECTION

sub keyevent { # We return the keyvalue, not the character.
   my $k = ReadKey(-1);
   my $ka;

   if ( length($k) ) {
      $ka = ord($k);
      return ($ka);
   }

   return ();
}

#### WRAPPERS for Term::Screen

# Term::Screen does not play well with others, so we
# have to wrap it instead of inherit it.

sub at          { my $self = shift; return ( $self->{'TERM'}->at(@_) ); }
sub bold        { my $self = shift; return ( $self->{'TERM'}->bold(@_) ); }
sub clreol      { my $self = shift; return ( $self->{'TERM'}->clreol(@_) ); }
sub clreos      { my $self = shift; return ( $self->{'TERM'}->clreos(@_) ); }
sub clrscr      { my $self = shift; return ( $self->{'TERM'}->clrscr(@_) ); }
sub cols        { my $self = shift; return ( $self->{'TERM'}->cols(@_) ); }
sub curinvis    { my $self = shift; return ( $self->{'TERM'}->curinvis(@_) ); }
sub curvis      { my $self = shift; return ( $self->{'TERM'}->curvis(@_) ); }
sub dc          { my $self = shift; return ( $self->{'TERM'}->dc(@_) ); }
sub dc_exists   { my $self = shift; return ( $self->{'TERM'}->dc_exists(@_) ); }
sub def_key     { my $self = shift; return ( $self->{'TERM'}->def_key(@_) ); }
sub DESTROY     { my $self = shift; return ( $self->{'TERM'}->DESTROY(@_) ); }
sub dl          { my $self = shift; return ( $self->{'TERM'}->dl(@_) ); }
sub echo        { my $self = shift; return ( $self->{'TERM'}->echo(@_) ); }
sub flush_input { my $self = shift; return ( $self->{'TERM'}->flush_input(@_) ); }
sub get_fn_keys { my $self = shift; return ( $self->{'TERM'}->get_fn_keys(@_) ); }
sub getch       { my $self = shift; return ( $self->{'TERM'}->getch(@_) ); }
sub ic          { my $self = shift; return ( $self->{'TERM'}->ic(@_) ); }
sub ic_exists   { my $self = shift; return ( $self->{'TERM'}->ic_exists(@_) ); }
sub il          { my $self = shift; return ( $self->{'TERM'}->il(@_) ); }
sub key_pressed { my $self = shift; return ( $self->{'TERM'}->key_pressed(@_) ); }
sub noecho      { my $self = shift; return ( $self->{'TERM'}->noecho(@_) ); }
sub normal      { my $self = shift; return ( $self->{'TERM'}->normal(@_) ); }
sub puts        { my $self = shift; return ( $self->{'TERM'}->puts(@_) ); }
sub resize      { my $self = shift; return ( $self->{'TERM'}->resize(@_) ); }
sub reverse     { my $self = shift; return ( $self->{'TERM'}->reverse(@_) ); }
sub rows        { my $self = shift; return ( $self->{'TERM'}->rows(@_) ); }
sub stuff_input { my $self = shift; return ( $self->{'TERM'}->stuff_input(@_) ); }
sub term        { my $self = shift; return ( $self->{'TERM'}->term(@_) ); }

#### EXIT

sub resetandexit { # reset the terminal settings before exit
   my $self = shift;
   $self->clrscr();
   ReadMode 0;        # Reset tty mode before exiting
   exit;
}

1;
