package Pdt::Form::Window;    # (P: w) EXPORTONLY

# #
my $VERSION = '2018-04-22.10-27-41.EDT';

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Window base class. Windows have multiple frames.
#: Each frame may have only one form. A window covers
#: the entire terminal area, and so has no geometry
#: functions, other than to clear, and to hand over
#: and take control of the terminal space to/from
#: other windows.

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);
use Pdt::Form::API;
our @ISA = qw(Pdt::Form::API);

use strict;

### CONSTRUCTORS

# we are derived only

### CALLBACKS

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'draw'}                = sub { shift; return $self->draw(@_); };
   $self->{'cbmap'}->{'drawblank'}           = sub { shift; return $self->drawblank(@_); };
   $self->{'cbmap'}->{'dropfocus'}           = sub { shift; return $self->dropfocus(@_); };
   $self->{'cbmap'}->{'focusnext'}           = sub { shift; return $self->focusnext(@_); };
   $self->{'cbmap'}->{'focusprev'}           = sub { shift; return $self->focusprev(@_); };
   $self->{'cbmap'}->{'formalign'}           = sub { shift; return $self->formalign(@_); };
   $self->{'cbmap'}->{'FRAMEGROUP'}          = sub { shift; return $self->FRAMEGROUP(@_); };
   $self->{'cbmap'}->{'KEYSET'}              = sub { shift; return $self->KEYSET(@_); };
   $self->{'cbmap'}->{'myform'}              = sub { shift; return $self->myform(@_); };
   $self->{'cbmap'}->{'setsig_windowchange'} = sub { shift; return $self->setsig_windowchange(@_); };
   $self->{'cbmap'}->{'takefocus'}           = sub { shift; return $self->takefocus(@_); };
   $self->{'cbmap'}->{'WINDOWFOCUS'}         = sub { shift; return $self->WINDOWFOCUS(@_); };
   $self->{'cbmap'}->{'WINDOWNAME'}          = sub { shift; return $self->WINDOWNAME(@_); };
   $self->{'cbmap'}->{'WINDOWORDER'}         = sub { shift; return $self->WINDOWORDER(@_); };

   return ( $self->{'cbmap'} );
}

#### INITIALIZATION

#### FOCUS

# STANDARD: takewindowfocus, dropwindowfocus, focusnextwindow, focusprevwindow
# CASCADABLE: takefocus, dropfocus, focusnext, focusprev

#### PDT::Form::API

# these functions are polymorphic

sub isfocused {
   my $self = shift;
   return ( $self->isfocusedwindow(@_) );
}

sub dropfocus {
   my $self = shift;
   return ( $self->dropwindowfocus(@_) );
}

sub takefocus {
   my $self = shift;
   return ( $self->takewindowfocus(@_) );
}

sub focusnext {
   my $self = shift;
   return ( $self->focusnextwindow(@_) );
}

sub focusprev {
   my $self = shift;
   return ( &focusprevwindow(@_) );
}

#### DRAWING

# for windows focus and draw are synonyms

sub drawblank {
   bonk "WINDOW", "\twindow drawblank requested: ", $_[ 0 ];
   &dropfocus(@_);
}

sub draw {
   bonk "WINDOW", "\twindow draw requested: ", $_[ 0 ];
   &takefocus(@_);
}

#####

#### SIGNAL HANDLING

sub setsig_windowchange { # default window change event, just redraws the window
   my $self = shift;

   my @OVQ;

   my $window_change_event = sub {
      $self->dropfocus();
      $self->takefocus();
   };

   my $event = newevent();
   $event->action($window_change_event);
   push @OVQ, $event;

   bonk 'WINDOW', "WINDOW SIG: windowchange:  ", $event, " ", $self->{'SIGNAL'};

   $self->{'FRAME'}->{'GEOM'}->{'SIGNAL'}->setsigque( 'WINCH', @OVQ );    # set the window change events

   return ();
}

### This needs to go to Pdt::Form::Form, and get eventalized

sub formalign { # align the form to provided values or center if none.
   my $self = shift;
   return undef unless defined $self->{'FRAME'};
   my $template = $self->{'FRAME'};

   bonk "UI", "Ucll has template: ", $template;

   unless ( length( $template->{'GEOM'} ) ) {
      bonk "UI", "Template ", $template, " does not have corresponding Pdt::Form object.";
      return undef;
   }

   my $form = $template->{'GEOM'};

   my $default = 'center';
   return ( $form->formalign($default) ) unless scalar(@_);
   return ( $form->formalign(@_) );
}

#### SHORTCUTS

sub myform { # the form assosciated with this UI regardless of focus
   return $_[ 0 ]->{'FRAME'}->{'GEOM'}->{'FORM'};
}

#### KEYSET

# in a window, the keyset is generally defined by calling the FRAME's keyset
# function. KEYSET is cascaded by function calls and updates a single common
# table, so the origin object of the call doesn't matter, the hook just has
# to be in the right place.

sub KEYSET {
   my $self = shift;

   if ( defined( $self->{'FRAME'} ) ) {
      $self->{'FRAME'}->KEYSET();
   }

   return ();
}

#### GENERIC SET/GET

sub WINDOWFOCUS { # (:M setget)
   my $self = shift;
   $self->{'WINDOWFOCUS'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'WINDOWFOCUS'};
}

sub WINDOWORDER { # (:M setget)
   my $self = shift;
   $self->{'WINDOWORDER'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'WINDOWORDER'};
}

sub WINDOWNAME { # (:M setget)
   my $self = shift;
   $self->{'WINDOWNAME'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'WINDOWNAME'};
}

sub FRAMEGROUP { # (:M setget) array.
   my $self = shift;

   if ( scalar(@_) ) {
      $self->{'FRAMEGROUP'} = [];
      push @{ $self->{'FRAMEGROUP'} }, @_;
   }

   return @{ $self->{'FRAMEGROUP'} };
}

1;
