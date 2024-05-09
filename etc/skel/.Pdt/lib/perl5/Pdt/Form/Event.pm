package Pdt::Form::Event;    # (P: o) EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Event que and container, events are formatted:
#:
#:  [window form widget pkey action redraw describe param ]
#:    0      1     2      3    4      5     6			7
#:
#: this is a bit backwards. There are two objects defined: a self registering array (the que) and
#: the events which are record objects. In both cases they statically class, so they can be
#: called with less syntax. Events have set/get object methods corresponding to their columns
#: (ui form widget pkey action redraw describe param), but those are not exported, just accessed via
#: object syntax, while que manipulation and constructors are accessed via exporter to reduce
#: syntactical load in the API.
#:

use Exporter;
use Data::Dumper qw(Dumper);
use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);

our @ISA    = qw(Exporter);
our @EXPORT = qw(describepending dumpevent dumppending newevent neweventque popevq pushevq redrawpending shiftevq unshiftevq quedevent pendingevent);
our %EXPORT_TAGS =
  ( 'all' => [ qw(describepending dumpevent dumppending newevent neweventque popevq pushevq redrawpending shiftevq unshiftevq quedevent pendingevent) ] );

use strict;

### CONSTRUCTORS

# first we generate an event que, which is a self registering
# array class.

sub neweventque { # autolithic array class, to contain events
   my $class = "Pdt::Form::EventQue";
   my ( $self, $start ) = AUTOQUE($class);    # self registering object
   return $self;
}

# then we can add and delete events as required, and refer to the
# columns by means o set/gets of the respective object columns. events
# and handed around as references.

#: format: [ $WINDOW, $CFFORM, $CFWIDGET, $pkey, $formaction, $formredraw ];

sub newevent { # simple record, with functions correlating to columns
   my $class = "Pdt::Form::Event";
   my $self  = \@_;
   bless $self, $class;

   # bonk "EVENT", "\tEVENT CREATED:", Dumper($self);
   return $self;
}

# these are shortcuts, and should generally be avoided except in cases
# where bulk static event profiles need to be created.

### EVENT OBJECT METHODS

# [window form widget pkey action redraw describe param ]
#   0      1     2      3    4      5     6			7

sub window { # user interface object handle
   my $self = shift;
   $self->[ 0 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 0 ];
}

sub form { # Pdt::Form::Form object
   my $self = shift;
   $self->[ 1 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 1 ];
}

sub widget { # Pdt::Form::Widget object
   my $self = shift;
   $self->[ 2 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 2 ];
}

sub pkey { # integer representing a pressed key
   my $self = shift;
   $self->[ 3 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 3 ];
}

sub action { # an anonymous callback, typically a
   my $self = shift;
   $self->[ 4 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 4 ];
}

sub redraw { # flag to induce a form redraw
   my $self = shift;
   $self->[ 5 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 5 ];
}

sub describe { # description of the current event.
   my $self = shift;
   $self->[ 6 ] = $_[ 0 ] if defined $_[ 0 ];
   return $self->[ 6 ];
}

sub param { # set/get params (untested)
   my $self = shift;
   my @staticfield = splice( @$self, 0, 6 );
   @$self = @_ if scalar(@_);
   my @param = @$self;
   unshift( @staticfield, @$self );
   return (@param);
}

sub appendparam { # append params (untested)
   my $self = shift;
   push( @$self, @_ ) if scalar(@_);
   my @staticfield = splice( @$self, 0, 5 );
   my @param = @$self;
   unshift( @staticfield, @$self );
   return @param;
}

sub runaction { # run the action callback
   my $self = shift;    # an event

   # if the action is a code reference it gets single
   # dispatch. if it is a word, multiple dispatch occurs
   # in the order of window, frame, widget. The dispatch
   # requires that the name be a callback mapped in cbmap
   # in the respective object

   return () unless ( length( $self->action() ) );

   # if the action is a code reference, run it
   # with the event as arguments

   my $A = $self->action();
   my $D = $self->describe();
   my @OVQ;

   if ( ref($A) eq 'CODE' ) {

      bonk "EVENT", "\trunaction coderef: ", $A, " ", $D, " ", quedevent();
      push @OVQ, &{$A}(@$self);
      bonk "EVENT", "\taction completed,  new events created: ", scalar(@OVQ);

   } else {

      # otherwise it may be a named callback.
      # walk the provided objects, and see
      # if callbacks exist.

      bonk "EVENT", "\trunaction named event: ", $A, " ", $D, " ", quedevent();

      my $W = $self->window();
      my $f = $self->form();
      my $F = $f->{'PARENTFRAME'};
      my $w = $self->widget();

      if ( defined($W) ) {
         if ( defined( $W->{'cbmap'} ) ) {
            if ( ref( $W->{'cbmap'}->{$A} ) eq 'CODE' ) {
               push @OVQ, &{ $W->{'cbmap'}->{$A} }(@$self);
            }
         }
      }

      if ( defined($F) ) {
         if ( defined( $F->{'cbmap'} ) ) {
            if ( ref( $F->{'cbmap'}->{$A} ) eq 'CODE' ) {
               push @OVQ, &{ $W->{'cbmap'}->{$A} }(@$self);
            }
         }
      }

      if ( defined($w) ) {
         if ( defined( $w->{'cbmap'} ) ) {
            if ( ref( $W->{'cbmap'}->{$A} ) eq 'CODE' ) {
               push @OVQ, &{ $w->{'cbmap'}->{$A} }(@$self);
            }
         }
      }
   }

   bonk "EVENT", "\trunaction generated: ", scalar(@OVQ), " new events.";

   return (@OVQ);
}

#### EVENT QUE EXPORTER FUNCTIONS

# count of events in que

sub quedevent { return scalar( @{ $::_AUTOLITH->{"Pdt::Form::EventQue"} } ); }

sub pendingevent { return ( $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ] ); }

sub describepending { # returns the describe field of the next event
   return () unless defined $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ];
   return ( $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ]->describe() );
}

sub redrawpending {
   return () unless defined $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ];
   return ( $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ]->redraw() );
}

sub dumppending {
   return () unless defined $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ];
   return ( Dumper( $::_AUTOLITH->{"Pdt::Form::EventQue"}->[ 0 ] ) );
}

sub dumpevent {
   my $self = shift;
   return Dumper($self);
}

sub pushevq { # (:M setget)
   my $self = $::_AUTOLITH->{"Pdt::Form::EventQue"};

   bonk 'EVENTQUE', "\tEVENTQUE: pushing ", scalar(@_), " new events.";

   my @OVQ;

   foreach (@_) {
      my $event = $_;
      unless ( ref($event) eq 'Pdt::Form::Event' ) {
         bonk "EVENTQUE", "EVENTQUE: fail pushing improperly generated event. use newevent()";
      } else {
         push @OVQ, $event;
      }
   }

   push @$self, @OVQ;

   @OVQ = ();

   return ();
}

sub unshiftevq { # (:M setget)
   my $self = $::_AUTOLITH->{"Pdt::Form::EventQue"};

   bonk 'EVENTQUE', "\tEVENTQUE: unshifting ", scalar(@_), " new events.";

   my @OVQ;

   foreach (@_) {
      my $event = $_;
      unless ( ref($event) eq 'Pdt::Form::Event' ) {
         bonk "EVENTQUE", "EVENTQUE: fail unshifting impropertly generated event. use newevent()";
      } else {
         push @OVQ, $event;
      }
   }

   unshift @$self, @OVQ;
   @OVQ = ();

   return ();
}

sub popevq { # 
   my $self = $::_AUTOLITH->{"Pdt::Form::EventQue"};

   if ( scalar(@$self) ) {
      my $event = pop @$self;

      unless ( ref($event) eq 'Pdt::Form::Event' ) {
         bonk "EVENTQUE", "EVENTQUE: fail popping improperly generated event. use newevent()";
         return ();
      }

      return $event;
   }

   return ();
}

sub shiftevq { # 
   my $self = $::_AUTOLITH->{"Pdt::Form::EventQue"};

   if ( scalar(@$self) ) {
      my $event = shift @$self;

      unless ( ref($event) eq 'Pdt::Form::Event' ) {
         bonk "EVENTQUE", "EVENTQUE: fail shifting improperly generated event. use newevent()";
         return ();
      }

      return $event;
   }

   return ();
}

1;
