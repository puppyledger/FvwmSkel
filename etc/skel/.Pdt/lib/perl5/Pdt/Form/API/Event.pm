package Pdt::Form::API::Event;    # EXPORTONLY (:P x)

# #
my $VERSION = '2018-04-13.07-05-04.EDT';

#: global events for the api

use Pdt::Bonk qw(:all);
use Pdt::Form::Event qw(:all);         # event container (provides newevent() constructor)
use Pdt::Form::API::Place qw(:all);    #
use Pdt::Form::Screen;                 # IO, Termcap, and Autocompletion
use Pdt::Form::Keymap;                 # Key dispatch Table
use Pdt::Form::Focus;                  # Focus Table
use Pdt::Form::Signal;
use Pdt::SourceEnv;

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT =
  qw(bindkeymap clearthisform clearthisformevent clearthiswidget clearthiswidgetevent clearthiswindow clearthiswindowevent clrscr dropformfocus dropframefocus dropwidgetfocus dropwindowfocus focusfirstform focusfirstformevent focusfirstframe focusfirstframeevent focusfirstwidget focusfirstwidgetevent focusfirstwindow focusfirstwindowevent focusform focusformevent focusnextform focusnextformevent focusnextwidget focusnextwidgetevent focusnextwindow focusnextwindowevent focusprevform focusprevformevent focusprevwidget focusprevwidgetevent focusprevwindow focusprevwindowevent focuswidget focuswidgetevent focuswindow focuswindowevent formbyname redraw redrawevent takeformfocus takeframefocus takewidgetfocus takewindowfocus thisform thiswidget thiswindow unbindkeymap widgetbyname windowbyname)
  ;                                    # (:C cbexport)

our %EXPORT_TAGS = (
   'all' => [
      qw(bindkeymap clearthisform clearthisformevent clearthiswidget clearthiswidgetevent clearthiswindow clearthiswindowevent clrscr dropformfocus dropframefocus dropwidgetfocus dropwindowfocus focusfirstform focusfirstformevent focusfirstframe focusfirstframeevent focusfirstwidget focusfirstwidgetevent focusfirstwindow focusfirstwindowevent focusform focusformevent focusnextform focusnextformevent focusnextwidget focusnextwidgetevent focusnextwindow focusnextwindowevent focusprevform focusprevformevent focusprevwidget focusprevwidgetevent focusprevwindow focusprevwindowevent focuswidget focuswidgetevent focuswindow focuswindowevent formbyname redraw redrawevent takeformfocus takeframefocus takewidgetfocus takewindowfocus thisform thiswidget thiswindow unbindkeymap widgetbyname windowbyname)
   ]
);                                     # (:C cbexport)

use strict;

############################# GRAPHICAL ###############################

#### DROP

sub dropwindowfocus { # clears the window, sets the windowisclear flag.
   my $self = shift;
   $self->clearthiswindow();           # Pdt::Form::API::Event
   $self->{'FOCUS'}->WINDOWISCLEAR(1);
   return ();
}

sub dropframefocus {
   my $self = shift;
   my $f    = $self->FORM();
   return ( $f->dropfocus() );
}

sub dropformfocus {
   my $self = shift;
   $self->{'SCREEN'}->curinvis();
   $self->drawblank();
   $self->draw();
   return ();
}

sub dropwidgetfocus {
   my $self = shift;
   $self->unbindkeymap();
   $self->{'SCREEN'}->curinvis();
   $self->drawblank();
   $self->draw();
   return ();
}

#### TAKE

# the way the cascade here works, is the objects all have
# takefocus() defined, which localizes to the API function
# of their type: takewindowfocus, takeframefocus etc.
#
# as the cascade occurs, the next branch always gets the
# generic takefocus() called, which allows for that class
# to define a more specific function, which then calls
# down to the next more specific function here in the API

sub takewindowfocus {
   my $self = shift;

   $self->clearthiswindow();

   foreach ( @{ $self->{'FRAMEGROUP'} } ) {
      my $F = $self->{'FOCUS'}->bynameframe($_);
      $F->drawblank();
      $F->draw();
      $F->takefocus() if $F;
   }

   $self->{'FOCUS'}->WINDOWISCLEAR(0);

   return ();
}

sub takeframefocus {
   my $self = shift;
   my $f    = $self->FORM();
   return ( $f->takefocus() );
}

sub takeformfocus {
   my $self = shift;

   bonk "FORM", "\ttakeformfocus: ", $self;

   $self->{'SCREEN'}->curinvis();
   $self->drawblank();
   $self->draw();

   return ();
}

sub takewidgetfocus {
   my $self = shift;
   $self->bindkeymap();
   $self->drawblank();
   $self->{'SCREEN'}->curvis();
   $self->draw();

   # unknown? $self->cur2pos() ;

   return ();
}

########################### ENDGRAPHICAL #############################

#### FIRST

sub focusfirstwindow { # 
   my $self = shift;

   bonk "EVENT", "\nEVENT ", $self, " focusfirstwindow";

   # get the oldwindow if one
   # get the firstwindow

   my $oldwindow = $self->{'FOCUS'}->thiswindow();
   my $newwindow = $self->{'FOCUS'}->firstwindow();

   bonk "EVENT", "\toldwindow newwindow: ", $oldwindow, ":", $newwindow;

   # set the new window

   my $window = $self->{'FOCUS'}->thiswindow($newwindow);

   bonk "EVENT", "\tcurrently focused window:", $window;

   unless ( $oldwindow eq $window ) {    #
      bonk "EVENT", "\t\twindow change request detected dropping focus: ", $oldwindow;

      if ( defined $oldwindow ) {
         $oldwindow->dropfocus();
      } else {
         $self->clearthiswindow();
      }

      bonk "EVENT", "\t\twindow change request detected taking focus: ", $window;

      $window->takefocus();
   }

   return ();
}

sub focusfirstwindowevent { # 
   my $self = shift;

   # events recieve the event at runtime,
   # and may multiple dispatch if multiple
   # objects are provided. This is by design.

   my $window = $self->thiswindow();
   my $form   = $self->thisform();
   my $widget = $self->thiswidget();
   my $desc   = 'PDT::Form::API::Event::focusfirstwindowevent';

   my $pkey = undef;

   my $action = sub { $self->focusfirstwindow(); };

   # REDRAW: undef = noredraw,  0 = que redraw, 1 = do the redraw

   my $formredraw = 0;

   my @param = ();

   my $E = newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param );

   bonk "EVENT", "\tAPI EVENT created focusfirstwindow: ", $E->describe();

   return ($E);
}

sub focusfirstframe {
   my $self = shift;

   bonk "EVENT", "\nEVENT ", $self, " focusfirstframe";

   # get the oldframe if one
   # get the firstframe

   my $oldframe = $self->{'FOCUS'}->thisframe();
   my $newframe = $self->{'FOCUS'}->firstframe();

   bonk "EVENT", "\toldframe newframe: ", $oldframe, ":", $newframe;

   # set the new frame

   my $frame = $self->{'FOCUS'}->thisframe($newframe);

   bonk "EVENT", "\tcurrently focused frame:", $frame;

   unless ( $oldframe eq $frame ) {    #
      bonk "EVENT", "\t\tframe change request detected dropping focus: ", $oldframe;

      $oldframe->dropfocus() if ( defined $oldframe );

      bonk "EVENT", "\t\tframe change request detected taking focus: ", $frame;

      $frame->takefocus();
   }

   return ();
}

sub focusfirstframeevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusfirstframeevent';

   my $action = sub { $self->focusfirstframe(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   my $E = newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param );

   bonk "EVENT", "\tAPI EVENT created focusfirstframe: ", $E->describe();

   return ($E);
}

sub focusfirstform {
   my $self = shift;

   bonk "EVENT", "\nEVENT ", $self, " focusfirstform";

   # get the oldform if one
   # get the firstform

   my $oldform = $self->{'FOCUS'}->thisform();
   my $newform = $self->{'FOCUS'}->firstform();

   bonk "EVENT", "\toldform newform: ", $oldform, ":", $newform;

   # set the new form

   my $form = $self->{'FOCUS'}->thisform($newform);

   bonk "EVENT", "\tfocusfirstform currently focused form: ", $form;

   unless ( $oldform eq $form ) {    #
      bonk "EVENT", "\t\tform change request detected dropping focus: ", $oldform;

      if ( defined $oldform ) {
         $oldform->dropfocus();
      }

   }

   bonk "EVENT", "\t\tform change request detected taking focus: ", $form;

   $form->takefocus();

   return ();
}

sub focusfirstformevent {
   my $self = shift;

   # events recieve the event at runtime,
   # and may multiple dispatch if multiple
   # objects are provided. This is by design.

   my $window = undef;
   my $form   = $self->thisform();
   my $widget = $self->thiswidget();
   my $desc   = 'PDT::Form::API::Event::focusfirstformevent';

   my $pkey = undef;

   my $action = sub { $self->focusfirstform(); };

   # REDRAW: undef = noredraw,  0 = que redraw, 1 = do the redraw

   my $formredraw = 0;

   my @param = ();

   my $E = newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param );

   bonk "EVENT", "\tAPI EVENT created focusfirstform: ", $E->describe();

   return ($E);
}

sub focusfirstwidget {
   my $self = shift;

   bonk "EVENT", "\nEVENT ", $self, " focusfirstwidget";

   # get the oldwidget if one
   # get the firstwidget

   my $oldwidget = $self->{'FOCUS'}->thiswidget();
   my $newwidget = $self->{'FOCUS'}->firstwidget();

   bonk "EVENT", "\toldwidget newwidget: ", $oldwidget, ":", $newwidget;

   # set the new widget

   my $widget = $self->{'FOCUS'}->thiswidget($newwidget);

   bonk "EVENT", "\tcurrently focused widget:", $widget;

   unless ( $oldwidget eq $widget ) {    #
      bonk "EVENT", "\t\twidget change request detected dropping focus: ", $oldwidget;

      $oldwidget->dropfocus() if ( defined $oldwidget );

      bonk "EVENT", "\t\twidget change request detected taking focus: ", $widget;

      $widget->takefocus();
   }

   return ();
}

sub focusfirstwidgetevent {
   my $self = shift;

   # events recieve the event at runtime,
   # and may multiple dispatch if multiple
   # objects are provided. This is by design.

   my $window = undef;
   my $form   = undef;
   my $widget = $self->thiswidget();
   my $desc   = 'PDT::Form::API::Event::focusfirstwidgetevent';

   my $pkey = undef;

   my $action = sub { $self->focusfirstwidget(); };

   # REDRAW: undef = noredraw,  0 = que redraw, 1 = do the redraw

   my $formredraw = 0;

   my @param = ();

   my $E = newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param );

   bonk "EVENT", "\tAPI EVENT created focusfirstwidget: ", $E->describe();

   return ($E);
}

#### CLEAR

# clear functions cascade depending on what level you call them at.

sub clrscr { # my $self = shift;
   my $self = shift;
   $self->{'FOCUS'}->WINDOWISCLEAR(1);
   return ( $self->{'SCREEN'}->clrscr() );
}

sub clearthiswindow { return ( &clrscr(@_) ); }

sub clearthiswindowevent { # (:M event)
   my $self = shift;

   # EVENT FORMAT:  [ window form widget pkey action redraw describe param ]

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;

   my $action = sub { $self->clearthiswindow(@_); };

   # redraw: undef does nothing, 0 ques redraw event, 1 flushes the redraw que

   my $formredraw = undef;

   my $describe = "\tclearthiswindowevent: $self";

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $describe, @param ) );
}

sub clearthisform { # my $self = shift;
   my $self = shift;
   my $F    = $self->thisform();
   return ( $F->clearform() );
}

sub clearthisformevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::clearthisformevent';

   my $action = sub { $self->clearthisform(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub clearthiswidget { # my $self = shift;
   my $self = shift;
   my $F    = $self->thisform();
   return ( $F->clearwidget() );
}

sub clearthiswidgetevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::clearthiswidgetevent';

   my $action = sub { $self->clearthiswidget(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

#### BYNAME

sub focuswindow { # done
   my $self = shift;
   my $name = shift;

   my $oldwindow = $self->thiswindow();
   my $newwindow = $self->windowbyname($name);

   # we don't need to avoid matches, because this
   # may be called as a refresh.

   $oldwindow->dropfocus() if ( defined $oldwindow );
   $newwindow->takefocus();

   $self->firstform();

   return ();
}

sub focuswindowevent { # (:M event)
   my $self = shift;

   my $window = undef;
   my $frame  = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focuswindowevent';

   my $action = sub { $self->focuswindow(@_); };

   # REDRAW: undef = noredraw,  0 = que redraw, 1 = do the redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $frame, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub focusform { # done
   my $self = shift;
   my $name = shift;

   my $oldform = $self->thisform();
   my $newform = $self->formbyname($name);

   $oldform->dropfocus() if ( defined $oldform );
   $newform->takefocus();

   $self->firstwidget();

   return ();
}

sub focusformevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusformevent';

   my $action = sub { $self->focusform(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub focuswidget { # done
   my $self = shift;
   my $name = shift;

   my $oldwidget = $self->thiswidget();
   my $newwidget = $self->widgetbyname($name);

   $oldwidget->dropfocus() if ( defined $oldwidget );
   $newwidget->takefocus();

   return ();
}

sub focuswidgetevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focuswidgetevent';

   my $action = sub { $self->focuswidget(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

#### NEXT

sub focusnextwindow {
   my $self = shift;
   my $W    = $self->thiswindow();
   $W->nextwindow();
   $self->firstform();
}

sub focusnextwindowevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusnextwindowevent';

   my $action = sub { $self->focusnextwindow(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub focusnextform {
   my $self = shift;
   my $F    = $self->thisform();
   $F->nextform();
   $self->firstwidget();
}

sub focusnextformevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusnextformevent';

   my $action = sub { $self->focusnextform(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub focusnextwidget {
   my $self = shift;
   my $W    = $self->thiswidget();
   $W->nextwidget();
}

sub focusnextwidgetevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusnextwidgetevent';

   my $action = sub { $self->focusnextwidget(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

#### PREV

sub focusprevwindow {
   my $self = shift;
   my $W    = $self->thiswindow();
   $W->prevwindow();
   $self->firstform();
}

sub focusprevwindowevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusprevwindowevent';

   my $action = sub { $self->focusprevwindow(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub focusprevform {
   my $self = shift;
   my $F    = $self->thisform();
   $F->prevform();
   $self->firstwidget();
}

sub focusprevformevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusprevformevent';

   my $action = sub { $self->focusprevform(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

sub focusprevwidget {
   my $self = shift;
   my $W    = $self->thiswidget();
   $W->prevwidget();
}

sub focusprevwidgetevent { # (:M event)
   my $self = shift;

   # typically these may be defined with this<type>()
   # methods or other similar methods from the api.

   my $window = undef;
   my $form   = undef;
   my $widget = undef;
   my $pkey   = undef;
   my $desc   = 'PDT::Form::API::Event::focusprevwidgetevent';

   my $action = sub { $self->focusprevwidget(@_); };

   # redraw states: undef = noredraw,  0 = que for redraw, 1 = redraw this and all qued for redraw

   my $formredraw = 0;

   my @param = ();

   return ( newevent( $window, $form, $widget, $pkey, $action, $formredraw, $desc, @param ) );
}

#### REDRAW FLAG

sub redraw {
   my $self = shift;
   pushevq( $self->redrawevent() );
}

sub redrawevent { # 
   my $self         = shift;
   my $callingclass = ref($self);

   my $E = newevent();
   $E->redraw(1);
   $E->describe("$callingclass requested a redraw event.");

   bonk "EVENT", "\tAPI EVENT created redraw: ", $E->describe();

   return ($E);
}

#### GLOBAL GET

sub thisform   { my $self = shift; return ( $self->{'FOCUS'}->thisform(@_) ); }
sub thiswidget { my $self = shift; return ( $self->{'FOCUS'}->thiswidget(@_) ); }
sub thiswindow { my $self = shift; return ( $self->{'FOCUS'}->thiswindow(@_) ); }

sub formbyname   { my $self = shift; return ( $self->{'FOCUS'}->formbyname(@_) ); }
sub widgetbyname { my $self = shift; return ( $self->{'FOCUS'}->widgetbyname(@_) ); }
sub windowbyname { my $self = shift; return ( $self->{'FOCUS'}->windowbyname(@_) ); }

#### KEYBINDING

# this should be callable from anywhere, but should always use
# the current window, form, and widget.

sub bindkeymap { # my $self = shift;
   my $self = shift;

   # since keybindings can potentially be modified during runtime,
   # we call KEYSET here. This does nothing in most circumstances.

   my $thiswidget = $self->thiswidget();
   $thiswidget->KEYSET();

#   bonk "FORM", "\tFORM ------- BINDKEYMAP -----------";
#   bonk "FORM", "\t\tself keymap: $self $self->{'KEYMAP'}";
#   bonk "FORM", "\t\tself thiswidget: $self ", $thiswidget;

   # KEYMAP->bindkeymap cascades the current form, widget, template
   # should window be here?

   $self->{'KEYMAP'}->bindkeymap();
}

sub unbindkeymap {
   my $self = shift;

   # bonk "FORM", "\tFORM ------- UNBINDKEYMAP -----------";
   $self->{'KEYMAP'}->unbindkeymap();
}

1;
