package Pdt::Form::Signal;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Signals in Pdt::Form, are simply converted into eventloop events
#: Because they precede normal events in importance, they go right
#: to the beginning of the que.

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Pdt::Form::Event qw(:all);
use Term::ReadKey;

# use Term::Read

our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Signal->newsignal(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newsignal {
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # self registering object

   if ($start) {                               # A, true only on first run. P, always true

      # here we define ques that store events for known system signals.
      # behavior may be modified by paging in and out of these event ques

      $self->{'WINCH'}    = [];    # events ques to
      $self->{'WARN'}     = [];    # warn events
      $self->{'QUIT'}     = [];    # events to do before quit
      $self->{'EXIT'}     = [];    # events to do before quit
      $self->{'BREAK'}    = [];    # events to do before quit
      $self->{'CONTINUE'} = [];    # events to do before quit

      $self->cbmap();              # create with C: cbmap
      $self->defaultbinding();     # set some acceptable defaults

      # bind signal <SIGNALNAME> => <EVENTQUE>

      $self->bindsig(
         'WINCH'    => "WINCH",
         '__WARN__' => "WARN",
         'QUIT'     => "QUIT",
         'EXIT'     => "EXIT",
         'BREAK'    => "BREAK",
         'CONTINUE' => "CONTINUE"
      );

      bonk "SIGNAL", "SIGNAL handler constructed.";

   }

   return $self;
}

### CALLBACKS

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'bindsig'}       = sub { shift; return $self->bindsig(@_); };
   $self->{'cbmap'}->{'defaultbind'}   = sub { shift; return $self->defaultbind(@_); };
   $self->{'cbmap'}->{'pushsigque'}    = sub { shift; return $self->pushsigque(@_); };
   $self->{'cbmap'}->{'setsigque'}     = sub { shift; return $self->setsigque(@_); };
   $self->{'cbmap'}->{'sig2event'}     = sub { shift; return $self->sig2event(@_); };
   $self->{'cbmap'}->{'spoofsig'}      = sub { shift; return $self->spoofsig(@_); };
   $self->{'cbmap'}->{'spoofsigwinch'} = sub { shift; return $self->spoofsigwinch(@_); };

   return ( $self->{'cbmap'} );
}

#### EVENT GENERATION

sub defaultbind { # Default signal bindings
   my $self = shift;

   my $exitreadmode = sub { ReadMode 0; };    # return the terminal to normal screen mode.

   $self->pushsigque( 'QUIT', actionevent($exitreadmode) );
   $self->pushsigque( 'EXIT', actionevent($exitreadmode) );

   return ();
}

sub sig2event { # take a block of events, and put them on the event que
   my $self = shift;
   return ( unshiftevq(@_) );                 # From Pdt::Form:Event
}

sub spoofsig { # take our registered window change events and send them to the event que
   my $self    = shift;
   my $evqname = shift;

   unless ( defined( $self->{$evqname} ) ) {
      bonk "SIGNAL", "SIGNAL attempt to spoof a signal that does not exist: $evqname";
   }

   if ( defined( $self->{$evqname} ) ) {
      return ( $self->sig2event( @{ $self->{$evqname} } ) );
   }

   return ();
}

# this is here to catch legacy code, which sould be updated to use the
# spoofsig('<SIG>') form.

sub spoofsigwinch { return $_[ 0 ]->spoofsig('WINCH'); }

#### BINDINGS

sub bindsig { # bind event que injection to a system signal
   my $self   = shift;
   my %sigmap = @_;

   foreach my $signame ( keys(%sigmap) ) {
      my $signame = shift;
      my $sigevq  = delete $sigmap{$signame};

      $SIG{$signame} = sub {
         $self->spoofsig($sigevq);
      };
   }

   return ();
}

sub setsigque { # set a named array into an event que.
   my $self   = shift;
   my $sigevq = shift;

   unless ( length($sigevq) ) {
      bonk "SIGNAL", "SIGNAL setsigque of undefined SIGNAL name";
      return ();
   }

   @{ $self->{$sigevq} } = @_;
   return ();
}

sub pushsigque { # append to a named signal event que
   my $self   = shift;
   my $sigevq = shift;

   unless ( defined $self->{'sigevq'} ) {
      bonk "SIGNAL", "SIGNAL pushsigque of undefined SIGNAL name";
      return ();
   }

   push @{ $self->{$sigevq} }, @_;
   return ();
}

1;
