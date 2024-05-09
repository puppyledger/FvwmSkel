package Pdt::Form::Widget;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-22.10-27-45.EDT';

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Indevidual Widget Geometry Container for Terminal Based Forms

# these are just set/gets, though type detection may be added for
# additional widget functionality. This should likely be done
# by importing mapped inheritance when the object is created?

use Pdt::O qw(:all);
use Pdt::Form;
use Pdt::Bonk qw(:all);
use Pdt::Form::API;
use Pdt::Form::Event qw(:all);
use Pdt::Form::Factory;
use Data::Dumper qw(Dumper);

our @ISA = qw(Pdt::Form::API);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Widget->newwidget(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newwidget { # 
   my $class      = shift;
   my %widgetprop = @_;

   my $wtype = $widgetprop{'ftype'};

   # we can grab the factory out of thin air because it is
   # autolithic.

   my $WF = Pdt::Form::Factory->new();
   my $self = $WF->newwidget( $wtype, %widgetprop );
   $self->WIDGETNAME( $self->fname() );

   bonk "WIDGET", "WIDGETNAME: ", $self, " ", $self->WIDGETNAME();

   return $self;
}

### CALLBACKS

# these are some experimental definitions of some standardized functions
# that can be inherited by all widgets.

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'debug_field'}  = sub { shift; return $self->debug_field(@_); };
   $self->{'cbmap'}->{'debug_fval'}   = sub { shift; return $self->debug_fval(@_); };
   $self->{'cbmap'}->{'draw'}         = sub { shift; return $self->draw(@_); };
   $self->{'cbmap'}->{'drawblank'}    = sub { shift; return $self->drawblank(@_); };
   $self->{'cbmap'}->{'dropfocus'}    = sub { shift; return $self->dropfocus(@_); };
   $self->{'cbmap'}->{'fcoloffset'}   = sub { shift; return $self->fcoloffset(@_); };
   $self->{'cbmap'}->{'fcuroffset'}   = sub { shift; return $self->fcuroffset(@_); };
   $self->{'cbmap'}->{'fecho'}        = sub { shift; return $self->fecho(@_); };
   $self->{'cbmap'}->{'ffocus'}       = sub { shift; return $self->ffocus(@_); };
   $self->{'cbmap'}->{'ffocusorder'}  = sub { shift; return $self->ffocusorder(@_); };
   $self->{'cbmap'}->{'ffullname'}    = sub { shift; return $self->ffullname(@_); };
   $self->{'cbmap'}->{'flength'}      = sub { shift; return $self->flength(@_); };
   $self->{'cbmap'}->{'fname'}        = sub { shift; return $self->fname(@_); };
   $self->{'cbmap'}->{'focusnext'}    = sub { shift; return $self->focusnext(@_); };
   $self->{'cbmap'}->{'focusprev'}    = sub { shift; return $self->focusprev(@_); };
   $self->{'cbmap'}->{'fpagehome'}    = sub { shift; return $self->fpagehome(@_); };
   $self->{'cbmap'}->{'frowoffset'}   = sub { shift; return $self->frowoffset(@_); };
   $self->{'cbmap'}->{'fselected'}    = sub { shift; return $self->fselected(@_); };
   $self->{'cbmap'}->{'ftype'}        = sub { shift; return $self->ftype(@_); };
   $self->{'cbmap'}->{'fvalue'}       = sub { shift; return $self->fvalue(@_); };
   $self->{'cbmap'}->{'KEYSET'}       = sub { shift; return $self->KEYSET(@_); };
   $self->{'cbmap'}->{'PARENTFORM'}   = sub { shift; return $self->PARENTFORM(@_); };
   $self->{'cbmap'}->{'PARENTFRAME'}  = sub { shift; return $self->PARENTFRAME(@_); };
   $self->{'cbmap'}->{'PARENTWINDOW'} = sub { shift; return $self->PARENTWINDOW(@_); };
   $self->{'cbmap'}->{'putscursor'}   = sub { shift; return $self->putscursor(@_); };
   $self->{'cbmap'}->{'putsevent'}    = sub { shift; return $self->putsevent(@_); };
   $self->{'cbmap'}->{'takefocus'}    = sub { shift; return $self->takefocus(@_); };
   $self->{'cbmap'}->{'TEMPLATE'}     = sub { shift; return $self->TEMPLATE(@_); };
   $self->{'cbmap'}->{'unmappedkey'}  = sub { shift; return $self->unmappedkey(@_); };
   $self->{'cbmap'}->{'WIDGETNAME'}   = sub { shift; return $self->WIDGETNAME(@_); };

   return ( $self->{'cbmap'} );
}

#### PDT::Form::API

# these functions are polymorphic

sub isfocused {
   my $self = shift;
   return ( $self->isfocusedwidget(@_) );
}

sub dropfocus {
   my $self = shift;
   return ( $self->dropwidgetfocus(@_) );
}

sub takefocus {
   my $self = shift;
   return ( $self->takewidgetfocus(@_) );
}

sub focusnext {
   my $self = shift;
   return ( $self->focusnextwidget(@_) );
}

sub focusprev {
   my $self = shift;
   return ( &focusprevwidget(@_) );
}

#### DRAWING

sub drawblank {
   my $self = shift;
}

sub draw {
   my $self = shift;
}

#### FUNCTIONS THAT SHOULD BE REDEFINED

sub putsevent { # given a key event, we print it to the screen
   my $self = shift;
   $self->{'TERM'}->putsevent(@_);
   bonk "WIDGET", "putsevent refered to term.", scalar(@_);
}

sub putscursor { # # the cursor position has to be a shared property.
   my $self = shift;

   bonk "WIDGET", "\tputscursor template: ", $self->{'FRAME'};

   $self->placefocus( ${ $self->{'FORM'} }, $self, $self->{'FRAME'}, $self->{'FRAME'}->{'GEOM'}->{'ALIGN'}, $self->{'SCREEN'}, $self->{'FOCUS'} );

   bonk "WIDGET", "putscursor, UNCONFIGURED FUNCTION", scalar(@_);
   bonk "WIDGET", Dumper($self);

   $self->{'SCREEN'}->puts( chr( $_[ 0 ] ) );
}

sub unmappedkey { # what to do if there is no map
   my $self = shift;

   # ($UI, $CFFORM, $CFWIDGET, $pkey, $formaction, $formredraw, @param) # event format

   $self->putscursor();
   $self->putsevent(@_);

   bonk "WIDGET", "unmapped key.", scalar(@_);

   # MUST return nothing, or an event  ;

   return ();
}

sub KEYSET { # (:M keyset)
   my $self = shift;

   unless ( defined $self->{'KEYSET'} ) {

      $self->keyadd(
         {
            '9'       => $self->{'cbmap'}->{'focusnext'},    # tab
            '2791900' => $self->{'cbmap'}->{'focuslast'}     # shift-tab
         }
      );

   }

   return $self->{'KEYSET'};
}

#### WIDGET VALUE SET/GET

# the field value is referenced to the actual template text value
# during registration. The fvalue function provides transparency
# to that value.

sub fvalue { # :M setget the fvalue
   my $self = shift;

   if ( ref( $self->{'fvalue'} eq 'REF' ) ) {
      ${ $self->{'fvalue'} } = $_[ 0 ] if ( defined $_[ 0 ] );
      return ${ $self->{'fvalue'} };
   }

   bonk "WIDGET", "$self setget was attempted, field was not a reference.";
}

#### generic set/gets

sub fcoloffset { # set/get
   my $self = shift;
   $self->{'fcoloffset'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'fcoloffset'};
}

sub fcuroffset { # set/get
   my $self = shift;
   $self->{'fcuroffset'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'fcuroffset'};
}

sub fecho { # set/get
   my $self = shift;
   $self->{'fecho'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'fecho'};
}

sub ffocus { # set/get
   my $self = shift;
   $self->{'ffocus'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'ffocus'};
}

sub ffocusorder { # set/get
   my $self = shift;
   $self->{'ffocusorder'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'ffocusorder'};
}

sub ffullname { # set/get
   my $self = shift;
   $self->{'ffullname'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'ffullname'};
}

sub flength { # set/get
   my $self = shift;
   $self->{'flength'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'flength'};
}

sub fname { # set/get
   my $self = shift;
   $self->{'fname'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'fname'};
}

sub fpagehome { # set/get
   my $self = shift;
   $self->{'fpagehome'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'fpagehome'};
}

sub frowoffset { # set/get
   my $self = shift;
   $self->{'frowoffset'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'frowoffset'};
}

sub fselected { # set/get
   my $self = shift;
   $self->{'fselected'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'fselected'};
}

sub ftype { # set/get
   my $self = shift;
   $self->{'ftype'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'ftype'};
}

#### REGISTRATION RELATED ACCESSORS

sub PARENTFORM { # (:M setget)
   my $self = shift;
   $self->{'PARENTFORM'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'PARENTFORM'};
}

sub PARENTFRAME { # (:M setget)
   my $self = shift;
   $self->{'PARENTFRAME'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'PARENTFRAME'};
}

sub PARENTWINDOW { # (:M setget)
   my $self = shift;
   $self->{'PARENTWINDOW'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'PARENTWINDOW'};
}

sub TEMPLATE { # (:M setget)
   my $self = shift;
   $self->{'TEMPLATE'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'TEMPLATE'};
}

sub WIDGETNAME { # (:M setget)
   my $self = shift;
   $self->{'WIDGETNAME'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'WIDGETNAME'};
}

#### DEBUGGING

sub debug_field { # debug a particular property
   my $self = shift;
   my $f    = shift;
   bonk "WIDGET", "WIDGET field $f: ", $self, " ", $self->{$f};
}

sub debug_fval { # check the in memory value against the screen value
   my $self = shift;
   bonk "WIDGET", "WIDGET fval: ", $self, " ", ${ $self->{'fval'} };
}

1;
