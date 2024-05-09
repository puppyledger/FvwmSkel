package Pdt::Form::Focus;    # (P: o) EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Pdt::Form::Focus page tables for defining display
#: and dispatch targets.

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);
use Pdt::Form::Event qw(:all);       # gives us newevent()
use Pdt::Form::API::Reg qw(:all);    # for lasttoken tools

our @ISA = qw(Pdt::O);

our $CURPOS = [ 0, 0 ];              # Terminal Cursor Position

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Focus->newfocus(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newfocus {
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   $self->AUTOPOPULATE(@_);

   # map our exportable functions

   if ($start) {

      # statics

      $self->cbmap();                          # create a method map

      # boolean flag, used to communicate whether there is anything
      # written to the screen currently or not.

      #### FLAGS

      $self->{'WINDOWISCLEAR'} = 1;

      #### POINTERS

      $self->{'THISWINDOW'} = undef;    # currently focused form
      $self->{'THISFRAME'}  = undef;    # currently focused form
      $self->{'THISFORM'}   = undef;    # currently focused form
      $self->{'THISWIDGET'} = undef;    # currently focused widget

      #### PAGED INDEXES

      # Window Focus Index

      $self->{'WFN'} = {};    # Window Focus Name Index
      $self->{'WFO'} = [];    # Window Focus Order Index

      # Frame Focus Pagable Index

      $self->{'FFN'} = {};    # Frame Focus Named Index
      $self->{'FFO'} = [];    # Frame Focus Order Index

      # Form Focus Pagable Index

      $self->{'fFN'} = {};    # Form Focus Named Index
      $self->{'fFO'} = [];    # Form Focus Order Index

      # Widget Focus Pagable index

      $self->{'wFN'} = {};    # Form Focus Named Index
      $self->{'wFO'} = [];    # Form Focus Order Index

      # these tables are persistent, and include the full object
      # tree. The three letter indexes are paged out of the tables.

      $self->{'WINDOWTABLE'} = {};    # windowname -> window object
      $self->{'FRAMETABLE'}  = {};    # framename -> frame object
      $self->{'FORMTABLE'}   = {};    # windowname -> formname -> form object
      $self->{'WIDGETTABLE'} = {};    # formname -> widgetname -> "buffer|widget"

      # there can be multiple forms per window, so they also need a focus order
      # while this refers to forms, these are actually templates.

   } else {

      # runtime completeness checks

   }

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.)

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'bynamebuffer'}     = sub { shift; return $self->bynamebuffer(@_); };
   $self->{'cbmap'}->{'bynameform'}       = sub { shift; return $self->bynameform(@_); };
   $self->{'cbmap'}->{'bynameframe'}      = sub { shift; return $self->bynameframe(@_); };
   $self->{'cbmap'}->{'bynamewidget'}     = sub { shift; return $self->bynamewidget(@_); };
   $self->{'cbmap'}->{'bynamewindow'}     = sub { shift; return $self->bynamewindow(@_); };
   $self->{'cbmap'}->{'firstform'}        = sub { shift; return $self->firstform(@_); };
   $self->{'cbmap'}->{'firstframe'}       = sub { shift; return $self->firstframe(@_); };
   $self->{'cbmap'}->{'firstwidget'}      = sub { shift; return $self->firstwidget(@_); };
   $self->{'cbmap'}->{'firstwindow'}      = sub { shift; return $self->firstwindow(@_); };
   $self->{'cbmap'}->{'focusbyname'}      = sub { shift; return $self->focusbyname(@_); };
   $self->{'cbmap'}->{'focuszeroforward'} = sub { shift; return $self->focuszeroforward(@_); };
   $self->{'cbmap'}->{'FRAMEFACTORY'}     = sub { shift; return $self->FRAMEFACTORY(@_); };
   $self->{'cbmap'}->{'nextform'}         = sub { shift; return $self->nextform(@_); };
   $self->{'cbmap'}->{'nextframe'}        = sub { shift; return $self->nextframe(@_); };
   $self->{'cbmap'}->{'nextwidget'}       = sub { shift; return $self->nextwidget(@_); };
   $self->{'cbmap'}->{'nextwindow'}       = sub { shift; return $self->nextwindow(@_); };
   $self->{'cbmap'}->{'PDTAPI'}           = sub { shift; return $self->PDTAPI(@_); };
   $self->{'cbmap'}->{'prevform'}         = sub { shift; return $self->prevform(@_); };
   $self->{'cbmap'}->{'prevframe'}        = sub { shift; return $self->prevframe(@_); };
   $self->{'cbmap'}->{'prevwidget'}       = sub { shift; return $self->prevwidget(@_); };
   $self->{'cbmap'}->{'prevwindow'}       = sub { shift; return $self->prevwindow(@_); };
   $self->{'cbmap'}->{'processkey'}       = sub { shift; return $self->processkey(@_); };
   $self->{'cbmap'}->{'registerform'}     = sub { shift; return $self->registerform(@_); };
   $self->{'cbmap'}->{'registerframe'}    = sub { shift; return $self->registerframe(@_); };
   $self->{'cbmap'}->{'registerwidget'}   = sub { shift; return $self->registerwidget(@_); };
   $self->{'cbmap'}->{'registerwindow'}   = sub { shift; return $self->registerwindow(@_); };
   $self->{'cbmap'}->{'syncframeform'}    = sub { shift; return $self->syncframeform(@_); };
   $self->{'cbmap'}->{'thisbuffer'}       = sub { shift; return $self->thisbuffer(@_); };
   $self->{'cbmap'}->{'thisform'}         = sub { shift; return $self->thisform(@_); };
   $self->{'cbmap'}->{'thisframe'}        = sub { shift; return $self->thisframe(@_); };
   $self->{'cbmap'}->{'thiswidget'}       = sub { shift; return $self->thiswidget(@_); };
   $self->{'cbmap'}->{'thiswindow'}       = sub { shift; return $self->thiswindow(@_); };
   $self->{'cbmap'}->{'WIDGETFACTORY'}    = sub { shift; return $self->WIDGETFACTORY(@_); };
   $self->{'cbmap'}->{'WINDOWFACTORY'}    = sub { shift; return $self->WINDOWFACTORY(@_); };
   $self->{'cbmap'}->{'WINDOWISCLEAR'}    = sub { shift; return $self->WINDOWISCLEAR(@_); };

   return ( $self->{'cbmap'} );
}

#### REGISTRATION

# registeration populates the TABLE, not the pagable indexes, except
# in the case of WINDOW, where they are the same, and must be
# known at startup.

sub registerwindow { # 
   my $self  = shift;
   my %param = @_;

   # populate the persistent table

   $self->{'WINDOWTABLE'}->{ $param{'windowname'} } = $param{'windowobject'};

   # populate the pagable table too. (might as well, it doesn't change)

   $self->{'WFN'}->{ $param{'windowname'} } = $param{'windowobject'};
   $self->{'WFO'}->[ $param{'windoworder'} ] = $param{'windowobject'};

   bonk "WINDOW", "\tFOCUS registering window complete: ", $param{'windowobject'};

   return ();
}

# frameregisteration interfaces with peer objects, which requires access
# to the factory. Most of the processing for registerframe therefore actually
# happens in Pdt::Form::API registerframe() and preregisterframe() :

sub registerframe { # 
   my $self  = shift;
   my %param = @_;

   my $G = $param{'frameobject'};

   # the G provides us access to the API global functions and the
   # template methods without contaminating the template namespace.

   $self->{'FRAMETABLE'}->{ $param{'framename'} } = $G;
   $self->{'FFN'}->{ $param{'framename'} }        = $G;
   $self->{'FFO'}->[ $param{'frameorder'} ]       = $G;

   bonk "FRAME", "\tFOCUS registering frame complete: ", $G;

   return ();
}

sub registerform { # windowname -> formobject
   my $self  = shift;
   my %param = @_;

   $self->{'FORMTABLE'}->{ $param{'windowname'} } = {} unless ( defined $self->{'FORMTABLE'}->{ $param{'windowname'} } );
   $self->{'FORMTABLE'}->{ $param{'windowname'} }->{ $param{'formname'} } = $param{'formobject'};

   $self->{'fFN'}->{ $param{'formname'} } = $param{'formobject'};
   $self->{'fFO'}->[ $param{'formorder'} ] = $param{'formobject'};

   bonk "FORM", "\tFOCUS registering form complete: ", $param{'formobject'};

   return ();
}

sub registerwidget { # formname -> widgetname -> widget | buffer
   my $self  = shift;
   my %param = @_;

   my $widgetname   = $param{'widgetname'};
   my $widgetobject = $param{'widgetobjet'};
   my $widgetbuffer = $widgetobject->{'fvalue'};    # this is a reference
   my $formname     = $param{'formname'};

   # registering a widget consists of blanking the named reference to

   # that widget in the widget table. adding a reference to the actual
   # widget, adding a reference to widget and content value, and
   # updating # the focusorder table in the form with the widgets
   # forcusorder.

   # $self->{'WIDGETTABLE'} = {};    # formname -> widgetname -> "buffer|widget"

   # make the formtable if it isn't there.

   $self->{'WIDGETTABLE'}->{$formname} = {} unless ( defined $self->{'WIDGETTABLE'}->{$formname} );

   # make the widget subtable if it isn't there

   $self->{'WIDGETTABLE'}->{$formname}->{$widgetname} = {} unless ( defined $self->{'WIDGETTABLE'}->{$formname}->{$widgetname} );

   # load the widget and the buffer reference.

   $self->{'WIDGETTABLE'}->{$formname}->{$widgetname}->{'widget'} = $widgetobject;
   $self->{'WIDGETTABLE'}->{$formname}->{$widgetname}->{'buffer'} = $widgetbuffer;

   bonk "FORM", "\tFOCUS registering widget complete: ", $param{'widgetobject'};

   # bonk "WIDGET", Dumper( $self->{'WIDGETTABLE'} );

   return ();
}

#### THIS

sub thiswindow { # set window and trunk frames, or get window
   my $self = shift;
   my $W    = shift;

   bonk "FOCUS", "\tthiswindow called with: ", $W;

   if ( defined($W) ) {
      $self->{'THISWINDOW'} = $W;

      # blank the frames table

      $self->{'FFN'} = {};
      $self->{'FFO'} = [];

      bonk "FOCUS", "\twindow framegroup: ", $W->{'FRAMEGROUP'};

      if ( ref( $W->{'FRAMEGROUP'} ) eq 'ARRAY' ) {

         # if the user has defined in the window a property FRAMEGROUP with
         # an array of names, those names are assumed to define all the frames
         # and forms that will populate the window.

         bonk "FOCUS", "\tthe supplied window had a framegroup: ", $W->{'FRAMEGROUP'};

         if ( scalar( @{ $W->{'FRAMEGROUP'} } ) ) {
            foreach my $tname ( @{ $W->{'FRAMEGROUP'} } ) {
               $tname =~ tr/A-Z/a-z/;
               foreach my $k ( keys( %{ $self->{'FRAMEFACTORY'}->{'cbmap'} } ) ) {
                  if ( $tname eq $k ) {
                     $self->{'FFN'}->{$k} = &{ $self->{'FRAMEFACTORY'}->{'cbmap'}->{$k} };
                     push @{ $self->{'FFO'} }, $self->{'FFN'}->{$k};
                  }
               }
            }

            bonk "FOCUS", "\tfocus table updated with new framegroup: ", scalar( @{ $self->{'FFO'} } );

         }
      }

      # THISWINDOW is defined at this level

      $self->syncframeform();

      bonk "FOCUS", "\tfocus table updated with new formgroup: ", scalar( @{ $self->{'fFO'} } );
   }

   bonk "FOCUS", "\tthiswindow returning: ", $self->{'THISWINDOW'};

   return $self->{'THISWINDOW'};
}

# NOTE: frames and forms operate synchronously. Any focus action
# on one should cause the same action on the other. The frame and
# form page table, is always defined by changing a window, so we
# don't have to have a syncformframe as well.

sub syncframeform { # frames and form index tables are always sync'd
   my $self = shift;

   $self->{'fFN'} = {};
   $self->{'fFO'} = [];

   foreach my $frame ( @{ $self->{'FFO'} } ) {
      my $G = $frame->GEOM();
      push @{ $self->{'fFO'} }, $G->FORM();
   }

   foreach my $k ( keys %{ $self->{'FFN'} } ) {
      my $G = $self->{'FFN'}->{$k}->GEOM();
      $self->{'fFN'}->{$k} = $G;
   }

   bonk "FOCUS", "\tframe/form synchro complete: ", scalar( @{ $self->{'FFO'} } ), " ", scalar( @{ $self->{'fFO'} } );

   return ();
}

# thisframe, thisform, are synchronous

sub thisframe { # 
   my $self = shift;
   my $F    = shift;

   bonk "FOCUS", "\t\tfocus frame received: ", $F;

   if ( defined $F ) {

      # we may recieve a template or a wrapper. We
      # want the wrapper, so we check and localize.

      my $fclass = ref($F);
      $F = $F->GEOM() unless ( $fclass eq 'Pdt::Form::Frame' );

      my $f = $F->FORM();
      bonk "FOCUS", "\t\tchild form: ", $f;

      $self->{'THISFRAME'} = $F;
      $self->{'THISFORM'}  = $f;

      $self->updatewidgetpage( $f->NAME() );
   }

   return ( $self->{'THISFRAME'} );
}

sub thisform { # 
   my $self = shift;
   my $f    = shift;    # form

   bonk "FOCUS", "\t\tfocus form received: ", $f;

   if ( defined $f ) {
      my $F = $f->PARENTFRAME();

      bonk "FOCUS", "\t\tparent frame: ", $F;

      $self->{'THISFRAME'} = $F;
      $self->{'THISFORM'}  = $f;

      $self->updatewidgetpage( $f->NAME() );
   }

   return ( $self->{'THISFORM'} );
}

sub updatewidgetpage {
   my $self = shift;

   my $formname = shift;
   $formname =~ tr/A-Z/a-z/;

   bonk "FOCUS", "\tform focus updating widget page for: ", $formname;

   $self->{'wFN'} = {};
   $self->{'wFO'} = [];

   # widgettable is not correctly formed.

   # HERE, registerwidget is broken.

   bonk "FOCUS", "\twidgettable defined: ", $self->{'WIDGETTABLE'}->{$formname}, " ", ( keys( %{ $self->{'WIDGETTABLE'}->{$formname} } ) );
   bonk "FOCUS", "\tincoming widget set: ", ( join ":", ( keys( %{ $self->{'WIDGETTABLE'}->{$formname} } ) ) );

   %{ $self->{'wFN'} } = %{ $self->{'WIDGETTABLE'}->{$formname} };

   # use the embedded widget order to make up the paged widget table.
   # then set the focus for the widget.

   foreach my $fname ( keys( %{ $self->{'wFN'} } ) ) {
      $self->{'wFO'}->[ $self->{'wFN'}->{$fname}->{'ffocusorder'} ] = $self->{'wFN'}->{$fname};
      if ( $self->{'wFN'}->{$fname}->{'ffocus'} ) {
         bonk "FOCUS", "\tinitializing thiswidget in form: ", $fname;
         $self->thiswidget( $self->{'wFN'}->{$fname} );
      }
   }

   # bonk "FOCUS", "\twidgets in new page: ", scalar( @{$self->{'wFO'} );

   return ();
}

sub thiswidget { # set/get currently focused widget
   my $self = shift;
   my $W    = shift;

   if ( defined $W ) {
      my $oldwidget = $self->{'THISWIDGET'};

      if ( defined $oldwidget ) {
         $oldwidget->{'ffocus'} = 0;
      }

      $W->{'ffocus'}        = 1;
      $self->{'THISWIDGET'} = $W;
   }

   return $self->{'THISWIDGET'};
}

sub thisbuffer { # get the buffer of the currently focused widget
   my $self = shift;
   my $W    = $self->thiswidget();
   return $W->{'fvalue'};    # this is a ref
}

#### FIRST

sub firstwindow { # get the root window
   my $self = shift;

   # the window table is static once registered.

   bonk "FOCUS", "\tfirstwindow requested: ", $self->{'WFO'}->[ 0 ];

   return ( $self->{'WFO'}->[ 0 ] );
}

sub firstframe { # 
   my $self = shift;

   # thiswindow populate the frame and form tables,
   # so all we should have to do here, is hand back
   # the first position.

   bonk "FOCUS", "\tfirstframe requested: ", $self->{'FFO'}->[ 0 ];

   return ( $self->{'FFO'}->[ 0 ] );
}

sub firstform { # 
   my $self = shift;

   # thiswindow populate the frame and form tables,
   # so all we should have to do here, is hand back
   # the first position.

   bonk "FOCUS", "\tfocus firstform requested: ", $self->{'fFO'}->[ 0 ];

   # HERE

   return ( $self->{'fFO'}->[ 0 ] );
}

sub firstwidget { # look for the first focusable widget in the form
   my $self = shift;
   my $WA   = shift;    # widget array

   # first widget returns the first non-disabled widget in
   # an array of widgets. Typically it operates on the
   # current form, but may be handed an alternate array,
   # which allows nextwidget, and prevwidget to use this
   # disablement detection as well.

   $WA = $self->{'wFO'} unless ( ref($WA) eq 'ARRAY' );

   for ( my $n = 0 ; $n < $#{$WA} ; $n++ ) {
      if ( length( $WA->[ $n ] ) ) {
         if ( $WA->[ $n ]->{'fdisable'} ) {
            next;
         } else {

            bonk "FOCUS", "firstwidget requested", $self->{'wFO'}->[ 0 ];

            return ( $WA->[ $n ] );
         }
      }
   }

   # there is no disabled widget

   return ();
}

#### BYNAME

sub bynamewindow { # return a window by name (must be lc)
   my $self = shift;
   my $name = shift;
   return $self->{'WFN'}->{$name};
}

sub bynameframe { # return a frame by name (must be lc)
   my $self = shift;
   my $name = shift;
   return $self->{'FFN'}->{$name};
}

sub bynameform { # get a form in the currently focused window by NAME
   my $self = shift;
   my $name = shift;
   return $self->{'fFN'}->{$name};
}

sub bynamewidget {
   my $self = shift;
   my $name = shift;
   return $self->{'wFN'}->{$name};
}

sub bynamebuffer { # get the buffer of a widget in thisform by widget fname
   my $self = shift;
   my $name = shift;
   return $self->{'wFN'}->{$name}->{'fvalue'};
}

#### NEXT

sub nextwindow { # get the window after the provided one (wizard style)
   my $self        = shift;
   my $reverseflag = shift;

   my $W          = $self->thiswindow();
   my $windowname = ref($W);

   my $n     = 0;
   my $match = undef;

   # find the object

   my @windowset = @{ $self->{'WFO'} };
   @windowset = reverse(@windowset) if $reverseflag;

   foreach my $w (@windowset) {
      $match = $n if ( $windowname eq ref($w) );
      last if ( defined $match );
      $n++;
   }

   return ( $windowset[ 0 ] ) if ( $match == $#windowset );
   $n++;

   return ( $windowset[ $n ] );
}

sub nextframe { # get the frame after the provided one (wizard style)
   my $self        = shift;
   my $reverseflag = shift;

   my $F         = $self->thisframe();
   my $framename = ref($F);

   my $n     = 0;
   my $match = undef;

   # find the object

   my @frameset = @{ $self->{'FFO'} };
   @frameset = reverse(@frameset) if $reverseflag;

   foreach my $f (@frameset) {
      $match = $n if ( $framename eq ref($f) );
      last if ( defined $match );
      $n++;
   }

   return ( $frameset[ 0 ] ) if ( $match == $#frameset );
   $n++;

   return ( $frameset[ $n ] );
}

sub nextform { # get the form after the current one.
   my $self        = shift;
   my $f           = shift;
   my $reverseflag = shift;
   my $F           = $f->{'PARENTFRAME'};
   $F = $self->nextframe( $F, $reverseflag );
   return $F->{'GEOM'}->{'FORM'};
}

sub nextwidget { # get the next window after the current one
   my $self        = shift;
   my $reverseflag = shift;

   my $widget = $self->thiswidget();
   return ( $self->firstwidget() ) unless ( defined $widget );

   my $thisname = $widget->{'fname'};

   my @widgetset = @{ $self->{'wFO'} };
   @widgetset = reverse(@widgetset) if $reverseflag;

   my $match;

   my $n = 0;

   foreach my $w (@widgetset) {
      $match = $n if ( $thisname eq $w->{'fname'} );
      last if ( defined $match );
      $n++;
   }

   # if we are at the end, we can just circle around

   return $self->firstwidget() if ( $match == $#widgetset );

   # if not we still want to be able to check for disables,
   # so we use the match index, and splice the end to
   # the front, and pass it to firstwidget, which gives
   # us the appearance of a loop.

   # HERE, probably this splice is wrong

   my @front = splice( @widgetset, $match, ( scalar(@widgetset) - $match ) );
   @widgetset = ( @front, @widgetset );

   return $self->firstwidget( \@widgetset );
}

#### PREV

sub prevwindow { # reverse nextwindow
   my $self = shift;
   $self->prevwindow(1);
}

sub prevframe { # reverse nextframe
   my $self = shift;
   $self->prevframe(1);
}

sub prevform { # reverse nextform
   my $self = shift;
   $self->nextform(1);
}

sub prevwidget { # 
   my $self = shift;
   $self->nextwidget(1);
}

### EVENT PROCESSING

sub processkey {
   my $self     = shift;
   my $template = shift;

   # @_ is now just an event formatted so:
   # ($UI, $CFFORM, $CFWIDGET, $pkey, $formaction, $formredraw, @param)

   my @E = @_;

   my $F = $self->thisform();
   my $W = $self->thiswidget();    # the currently focused widget

   $_[ 1 ] = $F;
   $_[ 2 ] = $W;

   my @newevent = $self->{'KEYMAP'}->processkey(@_);

   return @newevent;
}

sub focusbyname { # 
   my $self = shift;
   my %foo  = @_;

   # get the existing params
   my $formredraw;

   my $W  = $self->thiswindow();
   my $WN = $W->WINDOWNAME();      # inherited setget

   # if we change windows, full redraw will take place
   # from system events. no redraw is required.

   my $F  = $self->thisform();
   my $FN = $F->FORMNAME();      # inherited setget

   # we redraw forms on a change of form focus. This
   # allows popups to overlap, but not collide.

   $formredraw = 1 unless ( $F eq $FN );

   my $w  = $self->thiswidget();
   my $wn = $w->fname();           # inherited setget

   my @OVQ;

   if ( defined( $foo{'windowname'} ) ) {
      $WN = $foo{'windowname'};
      push @OVQ, $self->windowfocusevent( $W, $F, $w, undef, undef, undef );
   }

   if ( defined( $foo{'formname'} ) ) {
      $FN = $foo{'formname'};
      push @OVQ, $self->formfocusevent( $W, $F, $w, undef, undef, $formredraw );
   }

   if ( defined( $foo{'widgetname'} ) ) {
      $wn = $foo{'widgetname'};
      push @OVQ, $self->widgetfocusevent( $W, $F, $w, undef, undef, undef );
   }

   return (@OVQ);
}

#### SET/GETS

sub FRAMEFACTORY { # (:M setget)
   my $self = shift;
   $self->{'FRAMEFACTORY'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'FRAMEFACTORY'};
}

sub WIDGETFACTORY { # (:M setget)
   my $self = shift;
   $self->{'WIDGETFACTORY'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'WIDGETFACTORY'};
}

sub WINDOWFACTORY { # (:M setget)
   my $self = shift;
   $self->{'WINDOWFACTORY'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'WINDOWFACTORY'};
}

sub WINDOWISCLEAR { # (:M setget)
   my $self = shift;
   $self->{'WINDOWISCLEAR'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'WINDOWISCLEAR'};
}

sub PDTAPI { # (:M setget)
   my $self = shift;
   $self->{'PDTAPI'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'PDTAPI'};
}

1;
