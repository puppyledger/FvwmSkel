package Pdt::Form::API;    # (P: o) EXPORTONLY

# #
my $VERSION = '2018-04-22.10-27-53.EDT';

# #
my $VERSION = '2018-04-13.07-04-50.EDT';

#: The top level API object inits the core api code,
#: and provides universal methods for the API, the
#: most important of which is the init functions.

use Pdt::O qw(:all);       # Pdt SQLite connector

# globally accessible functions

use Pdt::Form::API::Reg qw(:all);      # Initial object registration functions for Window,Frame,Form,Widget
use Pdt::Form::API::Event qw(:all);    # Global event set.
use Pdt::Form::API::Place qw(:all);    # Global drawing functions.

# api state tables

use Pdt::Form::Keymap;                 # Key dispatch Table
use Pdt::Form::Focus;                  # Focus Table

# event dependencies

use Pdt::Form::Event qw(:all);         # event que, event objects, and field accessors
use Pdt::Form::Signal;                 # System signals.

# graphical dependencies

use Pdt::Form::Screen;                 # IO, Termcap, and Autocompletion
use Term::Size::Unix;

# API graphic state logic

use Pdt::Form::Factory;                # the widget factory
use Pdt::Form::Frame;
use Pdt::Form::Form;
use Pdt::Form::Widget;

# MISC

use Pdt::SourceEnv;
use Time::HiRes qw(sleep);             # decimalized sleep
use Sort::Naturally qw(nsort);         # default layouts are alphabetic.

# debugging dependencies

use Pdt::Bonk qw(:all);                # Debuging
use Data::Dumper qw(Dumper);
$Data::Dumper::Maxdepth = 1;

use Exporter;
our @ISA = qw(Pdt::O Exporter);

# This is both an OO and an exporter class. The exporter functions are global
# functions for all objects in the API, the nonexport functions are intended to be
# used in MAIN only.

our @EXPORT =
  qw(focusfirstform focusfirstwidget focusfirstwindow initapi thisform thiswidget thiswindow clearthiswindow clearthisform clearthiswidget bindkeymap unbindkeymap)
  ;    # (:C cbexport)
our %EXPORT_TAGS = (
   'all' => [
      qw(focusfirstform focusfirstwidget focusfirstwindow initapi thisform thiswidget thiswindow clearthiswindow clearthisform clearthiswidget bindkeymap unbindkeymap)
   ]
);     # (:C cbexport)

use strict;

### CONSTRUCTORS

#: newapi() does the initial construction of the major dependenices within the API
#: these are all AUTOLITH classes, and so can be new()d many times without memory
#: leaks.

#: initapi() provides localized importation of all of the api dependencies that are
#: created by newapi, and should be called by any object constructor that will be
#: a window,frame,form,widget

#: bootapi() collates templates (frames) into windows and then calls registerwindow
#: which cascades object registration down into any dependent api components that
#: need to keep track of what windows are where.

sub new { shift; Pdt::Form::API->newapi(@_); }

sub newapi { # construct the initial API dependencies
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # self registering object

   if ($start) {                               # A, true only on first run. P, always true

      $self->{'EVENTQUE'} = Pdt::Form::Event->neweventque();

      $self->{'SIGNAL'} = Pdt::Form::Signal->new( 'EVENTQUE' => $self->{'EVENTQUE'} );

      $self->{'SCREEN'} = Pdt::Form::Screen->new(
         'EVENTQUE' => $self->{'EVENTQUE'},
         'SIGNAL'   => $self->{'SIGNAL'}
      );

      $self->{'KEYMAP'} = Pdt::Form::Keymap->new(
         'SCREEN'   => $self->{'SCREEN'},
         'EVENTQUE' => $self->{'EVENTQUE'},
         'SIGNAL'   => $self->{'SIGNAL'}
      );

      $self->{'FOCUS'} = Pdt::Form::Focus->new(
         'SCREEN'   => $self->{'SCREEN'},
         'KEYMAP'   => $self->{'KEYMAP'},
         'EVENTQUE' => $self->{'EVENTQUE'},
         'SIGNAL'   => $self->{'SIGNAL'}
      );

      $self->{'KEYMAP'}->AUTOPOPULATE( 'FOCUS' => $self->{'FOCUS'} );

      # mainloop kill switch

      $self->{'CONTINUE'} = 1;

      # character read rate (decimal percent of second)

      $self->{'READINTERVAL'} = '0.005';

      # we have entered mainloop flag

      $self->{'FIRSTLOOP'} = 1;

      $self->cbmap();    # create with C: cbmap

      # set defaults here

   } else {

   }

   # anything not yet deleted autowrites to properties

   $self->AUTOPOPULATE(@_);

   # bonk "API", "API _________________________ ", Dumper($self) ;

   return $self;
}

#
# bootapi coalesces and instantiates all configured windows, frames, forms,
# widgets into Pdt::Form::Focus, which is the primary display state table.
#
# Then it goes through all the frames, forms and widgets to set their initial
# KEYSETS into memory to accelerate the UI.
#
# There may be a need for signal initialization as well?
#

sub bootapi { # my $self  = shift;
   my $self  = shift;
   my %param = @_;

   $self->AUTOPOPULATE(%param);

   # frame and window factories are user generated, and so must
   # be provided.

   die('cannot boot api without defined WINDOWFACTORY,FRAMEFACTORY')
     unless ( defined $self->{'WINDOWFACTORY'}
      && defined $self->{'FRAMEFACTORY'} );

   $self->{'WIDGETFACTORY'} = Pdt::Form::Factory->new();

   # The focus object needs the factories in order to page objects.

   $self->{'FOCUS'}->WINDOWFACTORY( $self->WINDOWFACTORY() );
   $self->{'FOCUS'}->FRAMEFACTORY( $self->FRAMEFACTORY() );
   $self->{'FOCUS'}->WIDGETFACTORY( $self->WIDGETFACTORY() );
   $self->{'FOCUS'}->PDTAPI($self);

   unless ( defined $self->{'WINDOWGROUP'} ) {
      bonk "API", "WINDOWGROUP undefined in API, assuming alphabetic focus orders";
   }

   # collate frames into windows with the FRAME property

   foreach my $k ( keys %{ $self->{'WINDOWFACTORY'}->{'cbmap'} } ) {
      my $W = &{ $self->{'WINDOWFACTORY'}->{'cbmap'}->{$k} };
      $self->{'FRAMEFACTORY'}->cbcollate( $W, 'FRAME' );
   }

   bonk "WINDOW", "BOOTAPI frame window collation complete";

   ##### FRAMEWORK INIT COMPLETE

   # note: initialization code should not create events. But
   # just in case we do something wonky we are going to
   # collect for events.

   my @OVQ;    # outgoing event que

   #### WINDOW REGISTRATION (AUTOLITH)

   # frames are automatically aggregated into windows by treeifying
   # the last class tokens of the frames. The tree is delinated
   # by "_" character.  So MyFrame::Foo, would be a master
   # frame, which will automatically render in window MyWindow::Foo.
   # MyFrame::Foo_bar will also render in window MyWindow::Foo

   # these relationships may be statically defined with a "WINDOWGROUP"
   # array in the window object, or will otherwised be processed
   # in alphabetic order.

   my @windoworder;

   @windoworder = @{ $self->{'WINDOWGROUP'} } if ( defined $self->{'WINDOWGROUP'} );
   @windoworder = nsort( keys( %{ $self->{'WINDOWFACTORY'}->{'cbmap'} } ) ) unless ( defined $self->{'WINDOWGROUP'} );

   # register all of the windows

   my $n = 0;

   foreach my $k (@windoworder) {
      $k =~ tr/A-Z/a-z/;
      if ( defined( $self->{'WINDOWFACTORY'}->{'cbmap'}->{$k} ) ) {
         my $W = &{ $self->{'WINDOWFACTORY'}->{'cbmap'}->{$k} };
         push @OVQ, $self->apiregisterwindow( $W, $n );
         $n++;
      }
   }

   bonk "WINDOW", "BOOTAPI registration events for $n windows created.";

   #### FRAME REGISTRATION (AUTOLITH)

   # Frames are factoried, but each grows a wrapper for itself during
   # its initial construction, due to the _init() function. This wrapper
   # is a Pdt::Form::Frame, and it is stored in a static variable in the
   # frame(template) package called $GEOM. Here we just grab the templates
   # and send them to the registration function, which separates out the
   # wrapper and registers it into FOCUS instead of the template.

   my @framecb = nsort( keys( %{ $self->{'FRAMEFACTORY'}->{'cbmap'} } ) );

   my $N = 0;

   foreach my $k (@framecb) {
      my $F = &{ $self->{'FRAMEFACTORY'}->{'cbmap'}->{$k} };
      push @OVQ, $self->apiregisterframe( $F, $N );
      $N++;
   }

   bonk "FRAME", "BOOTAPI registration for frames complete: ", $N;

   #### FORM REGISTRATION (PLUROLITH)

   # at this point FORM is still just a hash of properties in a Pdt::Form::Frame
   # object.

   my $_n = 0;

   foreach my $k (@framecb) {

      bonk "API", "BOOTAPI registering form by frame key:", $k;

      # get the template

      my $F = &{ $self->{'FRAMEFACTORY'}->{'cbmap'}->{$k} };

      # get the window

      my $wcb;
      my $W;

      if ( defined( $self->{'WINDOWFACTORY'}->{'cbmap'}->{$k} ) ) {
         $wcb = $self->{'WINDOWFACTORY'}->{'cbmap'}->{$k};
         bonk "API", "\twe have a parent window callback: ", $wcb;
      } else {
         my $_k = lowercasemastertoken($F);
         $wcb = $self->{'WINDOWFACTORY'}->{'cbmap'}->{$_k};
         bonk "API", "\twe have a master window callback: ", $k, " ", $_k, " ", $wcb;
      }

      next unless ( defined $wcb );
      $W = &$wcb;

      # WINDOW is defined

      # get the frame wrapper, (has the geometry)

      my $G = $F->GEOM();    # we want the wrapper not the template

      bonk "API", "\tFORM window frame geom:", $W, " ", $F, " ", $G;

      next unless ( defined $G );

      # FRAME is defined

      # master frames will have the same name as the window

      my $formparam = $G->FORM();

      # if there are no form parameters, we generate some defaults.

      unless ( ref($formparam) eq 'HASH' ) {
         bonk "API", "\tframe-template did not define a FORM hash. creating: ", $formparam;
         $formparam = $self->formparamfromframe( $F, $_n );    # TODO
      }

      ### create the form

      # reserve aside the alignment parameters.
      # alignments have to be built after COL/ROW are
      # populated to allow for offsets to be calculated

      my @alignparam = @{ $formparam->{'ALIGN'} };
      delete $formparam->{'ALIGN'};

      my $f = Pdt::Form::Form->new(%$formparam);

      $f->ALIGN(@alignparam);

      bonk "API", "\tinitial form object: ", $f;

      # put it back in the frame

      $G->FORM($f);

      # FORM is defined

      # here make sure that formorder is populated
      # whether it was defined or not

      my $order = $f->{'FORMORDER'};
      $order = $_n unless ( defined $order );
      $f->{'FORMORDER'} = $order;

      # bonk "API", "BOOTAPI review: window, template, framehandle, form, order: ", $W, " ", $F, " ", $G, " ", $f, " ", $order;

      push @OVQ, $self->apiregisterform( $W, $F, $G, $f, $order );

      $_n++;
   }

   bonk "FORM", "BOOTAPI registration for forms complete: ", $_n;

   #### WIDGET REGISTRATION (PLUROLITH)

   # Every form may have multiple widgets.

   my $_N = 0;

   foreach my $k (@framecb) {

      my $wcb = $self->{'WINDOWFACTORY'}->{'cbmap'}->{$k};

      unless ( defined $wcb ) {
         my $_k = lowercasemastertoken($k);
         $wcb = $self->{'WINDOWFACTORY'}->{'cbmap'}->{$_k};
      }

      # bail if the frame doesn't have a master window.
      # master window matches the last class text token, first
      # underscore delinated text element.

      next unless ( defined $wcb );

      my $W          = &$wcb;
      my $F          = &{ $self->{'FRAMEFACTORY'}->{'cbmap'}->{$k} };
      my $G          = $F->GEOM();
      my $f          = $G->FORM();
      my $windowname = $f->{'NAME'};

      # $F->{'GEOM'} should be a Pdt::Form by now?

      bonk "API", "\twidget registration begins: ", $W, ":", $F, ":", $G, ":", $f, ":", $windowname;

      my %widgethash = %{ $G->{'WIDGET'} };    # copy the widget tree

      $G->{'WIDGET'} = {};                     # waste the widget tree

      # widgets know their own order

      foreach my $K ( keys %widgethash ) {

         bonk "API", "\twidget key and parameters: ", $K, " ", ( join ":", ( keys( %{ $widgethash{$K} } ) ) );

         my $w = Pdt::Form::Widget->newwidget( %{ $widgethash{$K} } );

         $w->PARENTWINDOW($W);
         $w->TEMPLATE($F);
         $w->PARENTFRAME($G);
         $w->PARENTFORM($f);

         $G->{'WIDGET'}->{$K} = $w;

         bonk "API", "\twidget key and object: ", $K, " ", $G->{'WIDGET'}->{$K};

         push @OVQ, $self->apiregisterwidget( $W, $F, $G, $f, $w );

         $_N++;
      }
   }

   bonk "API", "BOOTAPI registration for widgets complete: ", $_N;

   # now that everything is registered, we accumulate the initial focus events to draw the windows

   push @OVQ, $self->focusfirstwindowevent();

   # anything geometry functions called on a frame should cascade down to a form.

   # push @OVQ, $self->focusfirstframeevent();

   push @OVQ, $self->focusfirstformevent();
   push @OVQ, $self->focusfirstwidgetevent();
   push @OVQ, $self->redrawevent();

   $self->{'FOCUS'}->WINDOWISCLEAR(0);

   bonk "API", "BOOTAPI created ", scalar(@OVQ), " events.";

   return @OVQ;
}

sub initapi { # universal API importer
   my $self = shift;

   # these must all AUTOLITH or EXPORTER only classes, as this function is called
   # in every form and widget.

   use Pdt::Bonk qw(:all);
   use Pdt::Form::API qw(:all);
   use Pdt::Form::Event qw(:all);        # event container (provides newevent() constructor)
   use Pdt::Form::Signal;                # Process signal regime
   use Pdt::Form::Screen;                # IO, Termcap, and Autocompletion
   use Pdt::Form::Keymap qw(:keyset);    # Key dispatch Table
   use Pdt::Form::Focus;                 # Focus Table
   use Term::Size::Unix;

   # here for doc purposes. Don't uncomment these, they are all found in
   # Pdt::Form::Form

   # use Pdt::Form::Window;
   # use Pdt::Form::Form;
   # use Pdt::Form::Widget;

   # eventque is here for good measure, however note that it exports
   # all the functions required to manipulate it, and no direct interaction
   # should be required. It is here for debuggin purposes.

   $self->{'EVENTQUE'} = Pdt::Form::Event->neweventque();

   # These all provide core functionality for the whole API and
   # are integral to every window, form, and widget.

   $self->{'PDTAPI'} = Pdt::Form::API->new();
   $self->{'SIGNAL'} = Pdt::Form::Signal->new();
   $self->{'SCREEN'} = Pdt::Form::Screen->new();
   $self->{'KEYMAP'} = Pdt::Form::Keymap->new();
   $self->{'FOCUS'}  = Pdt::Form::Focus->new();

   return 1;
}

### CALLBACKS

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'apiregisterform'}       = sub { shift; return $self->apiregisterform(@_); };          #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'apiregisterframe'}      = sub { shift; return $self->apiregisterframe(@_); };         #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'apiregisterwidget'}     = sub { shift; return $self->apiregisterwidget(@_); };        #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'apiregisterwindow'}     = sub { shift; return $self->apiregisterwindow(@_); };        #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'bindkeymap'}            = sub { shift; return $self->bindkeymap(@_); };               #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'bootapi'}               = sub { shift; return $self->bootapi(@_); };
   $self->{'cbmap'}->{'clearthisform'}         = sub { shift; return $self->clearthisform(@_); };            #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'clearthisformevent'}    = sub { shift; return $self->clearthisformevent(@_); };       #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'clearthiswidget'}       = sub { shift; return $self->clearthiswidget(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'clearthiswidgetevent'}  = sub { shift; return $self->clearthiswidgetevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'clearthiswindow'}       = sub { shift; return $self->clearthiswindow(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'clearthiswindowevent'}  = sub { shift; return $self->clearthiswindowevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'clrscr'}                = sub { shift; return $self->clrscr(@_); };                   #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'dropformfocus'}         = sub { shift; return $self->dropformfocus(@_); };            #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'dropframefocus'}        = sub { shift; return $self->dropframefocus(@_); };           #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'dropwidgetfocus'}       = sub { shift; return $self->dropwidgetfocus(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'dropwindowfocus'}       = sub { shift; return $self->dropwindowfocus(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstform'}        = sub { shift; return $self->focusfirstform(@_); };           #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstformevent'}   = sub { shift; return $self->focusfirstformevent(@_); };      #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstframe'}       = sub { shift; return $self->focusfirstframe(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstframeevent'}  = sub { shift; return $self->focusfirstframeevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstwidget'}      = sub { shift; return $self->focusfirstwidget(@_); };         #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstwidgetevent'} = sub { shift; return $self->focusfirstwidgetevent(@_); };    #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstwindow'}      = sub { shift; return $self->focusfirstwindow(@_); };         #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusfirstwindowevent'} = sub { shift; return $self->focusfirstwindowevent(@_); };    #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusform'}             = sub { shift; return $self->focusform(@_); };                #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusformevent'}        = sub { shift; return $self->focusformevent(@_); };           #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusnextform'}         = sub { shift; return $self->focusnextform(@_); };            #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusnextformevent'}    = sub { shift; return $self->focusnextformevent(@_); };       #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusnextwidget'}       = sub { shift; return $self->focusnextwidget(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusnextwidgetevent'}  = sub { shift; return $self->focusnextwidgetevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusnextwindow'}       = sub { shift; return $self->focusnextwindow(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusnextwindowevent'}  = sub { shift; return $self->focusnextwindowevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusprevform'}         = sub { shift; return $self->focusprevform(@_); };            #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusprevformevent'}    = sub { shift; return $self->focusprevformevent(@_); };       #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusprevwidget'}       = sub { shift; return $self->focusprevwidget(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusprevwidgetevent'}  = sub { shift; return $self->focusprevwidgetevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusprevwindow'}       = sub { shift; return $self->focusprevwindow(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focusprevwindowevent'}  = sub { shift; return $self->focusprevwindowevent(@_); };     #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focuswidget'}           = sub { shift; return $self->focuswidget(@_); };              #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focuswidgetevent'}      = sub { shift; return $self->focuswidgetevent(@_); };         #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focuswindow'}           = sub { shift; return $self->focuswindow(@_); };              #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'focuswindowevent'}      = sub { shift; return $self->focuswindowevent(@_); };         #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'formbyname'}            = sub { shift; return $self->formbyname(@_); };               #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'formparamfromframe'}    = sub { shift; return $self->formparamfromframe(@_); };
   $self->{'cbmap'}->{'initapi'}               = sub { shift; return $self->initapi(@_); };
   $self->{'cbmap'}->{'isfocusedform'}         = sub { shift; return $self->isfocusedform(@_); };
   $self->{'cbmap'}->{'isfocusedframe'}        = sub { shift; return $self->isfocusedframe(@_); };
   $self->{'cbmap'}->{'isfocusedwidget'}       = sub { shift; return $self->isfocusedwidget(@_); };
   $self->{'cbmap'}->{'isfocusedwindow'}       = sub { shift; return $self->isfocusedwindow(@_); };
   $self->{'cbmap'}->{'lowercaselastobject'}   = sub { shift; return $self->lowercaselastobject(@_); };      #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'lowercaselasttoken'}    = sub { shift; return $self->lowercaselasttoken(@_); };       #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'lowercasemastertoken'}  = sub { shift; return $self->lowercasemastertoken(@_); };     #	Pdt::Form::API::Reg
   $self->{'cbmap'}->{'mainloop'}              = sub { shift; return $self->mainloop(@_); };
   $self->{'cbmap'}->{'pollevent'}             = sub { shift; return $self->pollevent(@_); };
   $self->{'cbmap'}->{'processaction'}         = sub { shift; return $self->processaction(@_); };
   $self->{'cbmap'}->{'processredraw'}         = sub { shift; return $self->processredraw(@_); };
   $self->{'cbmap'}->{'redraw'}                = sub { shift; return $self->redraw(@_); };                   #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'redrawevent'}           = sub { shift; return $self->redrawevent(@_); };              #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'takeformfocus'}         = sub { shift; return $self->takeformfocus(@_); };            #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'takeframefocus'}        = sub { shift; return $self->takeframefocus(@_); };           #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'takewidgetfocus'}       = sub { shift; return $self->takewidgetfocus(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'takewindowfocus'}       = sub { shift; return $self->takewindowfocus(@_); };          #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'thisform'}              = sub { shift; return $self->thisform(@_); };                 #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'thiswidget'}            = sub { shift; return $self->thiswidget(@_); };               #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'thiswindow'}            = sub { shift; return $self->thiswindow(@_); };               #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'unbindkeymap'}          = sub { shift; return $self->unbindkeymap(@_); };             #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'widgetbyname'}          = sub { shift; return $self->widgetbyname(@_); };             #	Pdt::Form::API::Event
   $self->{'cbmap'}->{'windowbyname'}          = sub { shift; return $self->windowbyname(@_); };             #	Pdt::Form::API::Event

   return ( $self->{'cbmap'} );
}

#### MAINLOOP

sub mainloop {
   my $self = shift;

   bonk "MAIN", "\n\#\n\#\n\#\n ________ MAINLOOP START _________\n\#\n\#\n\#";

   # flag to redraw the form
   my $redrawthisform = undef;

   # Minor Redraw Events: Redraw events are devided into major and minor events
   # identified by 1 or 0 in the redraw column o the event. Minor events que,
   # major events empty the que. All non-redraw events should be undef.
   # This provides for a read-ahead functionality.

   my @MRE;

   my $loopcount = 0;

   while ( $self->{'CONTINUE'} ) {    #

      bonk "MAIN", "LOOPCOUNT: ", $loopcount;
      $loopcount++;

      # redraw flag is passed from rear to front. This allows read forwards.

      if ( $redrawthisform == 1 ) {

         my $E = shiftevq();          # get the event
         bonk 'MAIN', "MAIN major redraw event requested with ", scalar(@MRE), " minor events present.";

         $self->processredraw( @MRE, $E );

         @MRE                 = ();
         $redrawthisform      = undef;
         $self->{'FIRSTLOOP'} = 0;
         next;

      }

      # check for race conditions and crash if found,

      bonk "MAIN", "MAIN Que count: ", quedevent();

      if ( quedevent() > 1000 ) {
         die("Que count exceeded 1000. Failure to clear que, or a race condition. Bailing out!");
      }

      # take a beat

      $self->{'READINTERVAL'} = 0.005 unless defined $self->{'READINTERVAL'};
      sleep( $self->{'READINTERVAL'} );

      # if we have no events, try and find some, shorten if none.

      unless ( quedevent() ) {    # no events in que
         bonk "MAIN", "No events in que. Processing for new events.";    #

         # here we check the terminal for key events, which will typically
         # return an action event which is just placed in the que.

         $self->pollevent();
         $self->{'FIRSTLOOP'} = 0;

         next;
      }

      # we have an event. If it isn't a redraw event process it as an action.

      my $thisevent = pendingevent();

      bonk "MAIN", "MAIN eventque and pending event: ", $self->{'EVENTQUE'}, " ", $thisevent;

      # bonk "MAIN", "MAIN nextevent description: ", $thisevent->dumpevent();

      unless ( defined( $thisevent->redraw() ) ) {    # redraw must be defined to process

         bonk "MAIN", "MAIN Non-redraw event detected. ", quedevent();

         $self->processaction();                      # processevent handles formactions

         bonk "MAIN", "MAIN Event processing complete. ", quedevent();

         $self->{'FIRSTLOOP'} = 0;
         next;
      }

      #
      # $self->{'EVENTQUE'}->[0] at this point must be a redraw event.
      # redraw events with a 1 stay and loop, and are deleted at
      # the top of the loop.
      #
      # redraw events with a 0 process and delete and que, then continue
      # until a non-redraw event, or a 1 redraw event is
      # discovered.
      #

      #### REDRAW

      bonk "MAIN", "REDRAW event detected. ", scalar( @{ $self->{'EVENTQUE'} } );

      # [window form widget pkey action redraw desc param]
      #   0      1     2      3    4      5     6	 7

      my $trimlength = 0;    # how many events may be discarded

      # the pending event is evaluated for its redraw status:

      if ( redrawpending() == 1 ) {    # major redraw event requested

         # major redraw events occur with a 1, and they forward back to the
         # top. Minor redraw events may have been accumulated before this
         # happens.

         $redrawthisform = 1;

         bonk "MAIN", "MAIN major redraw event detected, returning to top.";

         next;

      } elsif ( redrawpending() == 0 ) {    # que redraw event

         bonk "MAIN", "\tminor redraw event detected.\n\tattempting to read ahead from: ", describepending();

         # If we catch a minor redraw event, we read ahead and accumulate all
         # minor redraws until we get to either a major redraw, or a non-redraw
         # event. Then we cycle back to the top. This bypasses our loop timers.

         my $endreadahead = 0;

         while ( $endreadahead < 1 ) {
            push @MRE, shiftevq();

            if ( redrawpending() == 1 ) {
               $endreadahead++;
               $redrawthisform = 1;
            }

            $endreadahead++ unless ( defined( redrawpending() ) );
         }

         bonk "MAIN", "\tminor redraw events accumulated: ", scalar(@MRE);

         next;

      }
      bonk 'MAIN', "MAIN we should never get here.";
   }

}

sub pollevent {
   my $self = shift;

   # look for new events in he form of keyboard events.
   # Note: sigevents don't need our help, they are already
   # bound to whatever code they need.

   # bonk "MAIN", "\tbegin newevent processing.", scalar( @$self->{'EVENTQUE'} );

   # ui, form, widget, key, action, redraw, %param

   # check non-blocking for a key events and hand them back
   # the key event is not processed here, but the event
   # goes back to the top of the loop.

   bonk "MAIN", "\tchecking for keys.";

   my @pkey = $self->{'SCREEN'}->keyevent();

   bonk "MAIN", "\tkeys found? ", scalar(@pkey);

   if ( scalar(@pkey) ) {    #

      bonk "MAIN", "\tMAIN KEYPRESS ", $pkey[ 0 ], ":", quedevent();

      # grab the currently focused widgets.

      my $CFWINDOW = $self->thiswindow();
      my $CFFORM   = $self->thisform();
      my $CFWIDGET = $self->thiswidget();

      bonk "MAIN", "\tMAIN Current WFW: ", $CFWINDOW, ":", $CFFORM, ":", $CFWIDGET;

      # now we need to convert a detected key, into event dispatch.

      my $keyeventcount;

      foreach my $k (@pkey) {    #
         bonk "MAIN", "\tMAIN key2keyevent: ", ( $CFWINDOW, ":", $CFFORM, ":", $CFWIDGET, $k );
         pushevq( $self->{'KEYMAP'}->key2keyevent( $CFWINDOW, $CFFORM, $CFWIDGET, $k ) );
      }

      bonk "MAIN", "\tMAIN key generated events: ", quedevent();
   }
   return ();
}

sub processaction {
   my $self = shift;

   if ( length( $self->{'EVENTQUE'}->[ 0 ]->pkey() ) ) {    # This is a pressed key event

      # [window form widget pkey action redraw param]
      #   0      1     2      3    4      5     6

      # when a key is pressed it generates an event. That event is dispatched
      # by the keymap table, which should handback either a specialized callback
      # or a default one. There should never be a case when we recieve a key event
      # that doesn't have a callback bound to it. (unmappedkey() is a REQUIREMENT of widgets)

      bonk "MAIN", "\tKEY event found: ", quedevent(), " ", $self->{'EVENTQUE'}->[ 0 ]->pkey();

      my $E = shiftevq();

      if ( length( $E->action() ) ) {    # a keypress generated callback

         bonk "MAIN", "\tKEY event had a bound action: ", quedevent(), " ", ref( $E->action() ), " ", scalar( $E->param() );

         $E->runaction();

         bonk "MAIN", "\tKey event action executed:", quedevent();

         undef $E;

      } else {

         # this shouldn't happen. key2keyevent looks for an unmappedkey() handler for
         # default dispatch. unmappedkey() is considered required for widgets. However
         # unmappedkey() may relay an undef action, to generate this error?

         bonk "MAIN", "\tabandoned key: ", $E->pkey(), " ", scalar( @$self->{'EVENTQUE'} );
         $E = undef;
      }

      return ();

   } elsif ( length( $self->{'EVENTQUE'}->[ 0 ]->action() ) ) {    # a callback event not generated by keystroke

      bonk "MAIN", "\tACTION found. ", quedevent(), " ", ref( $self->{'EVENTQUE'}->[ 0 ]->action() );

      my $E = shiftevq();

      bonk "MAIN", "\tdiscovered callback: ", $E->action();
      $E->runaction();                                             # params in an event pass.
      $E = undef;

      bonk "MAIN", "\tNon-key event processed. ", quedevent();

      return ();

   } else {

      my $E = shiftevq();

      bonk "MAIN", "Unknown event: ", quedevent(), " ", join( ',', (@$E) );

   }

   return ();
}

sub processredraw { # runs redraw on the biggest available object (window,form,widget)
   my $self = shift;
   my @MRE  = @_;      # minor redraw events

   # the major redraw event is at the end of the minor redraw events.

   my @OVQ;            # outbound event que
   my $nec;            # new event counter

   # as yet it is undetermined whether any layout logic should go here.
   # the current view is that it should not.

   my $mec = scalar(@MRE);    # minor event count

   bonk "SCREEN", "\nMAIN processredraw: ", $mec, " events recieved.";

   # walk through the redraw events and execute them

   for ( my $n = 0 ; $n < $mec ; $n++ ) {
      bonk "SCREEN", "\nREDRAWLOOP process event: ", $n, " ", $MRE[ $n ]->describe();
      push @OVQ, $MRE[ $n ]->runaction();
   }

   # delete the events.

   @MRE = ();

   # all events can cascade additional events

   bonk "SCREEN", "\tMAIN processredraw secondary events created: ", scalar(@OVQ);

   return (@OVQ);
}

#### MISC

sub formparamfromframe { # create a form scaffold for a frame if it is undefined.
   my $self  = shift;
   my $F     = shift;
   my $order = shift;

   my $class     = ref($F);
   my @token     = split( /\:\:/, $class );
   my $lasttoken = pop @token;
   my $lclt      = $lasttoken;
   $lclt =~ tr/A-Z/a-z/;

   my $formparam = {};
   my $formgroup = [];
   push @$formgroup, $lclt;

   $formparam->{'NAME'}        = $lasttoken;
   $formparam->{'FORMGROUP'}   = @$formgroup;
   $formparam->{'FORMORDER'}   = $order;
   $formparam->{'COL'}         = 0;
   $formparam->{'ROW'}         = 0;
   $formparam->{'ALIGN'}       = [ "place", 0, 0 ];
   $formparam->{'REPLACEMODE'} = undef;

   bonk "API", "\twarning: returning a blank form param scaffold.";
   return ($formparam);
}

#### FOCUS DETECTION

sub isfocusedwindow {
   my $self      = shift;
   my $isfocused = $self->thiswindow();
   return 1 if ( ref($self) eq ref($isfocused) );
   return 0;
}

sub isfocusedframe {
   my $self      = shift;
   my $isfocused = $self->thisframe();
   return 1 if ( ref($self) eq ref($isfocused) );
   return 0;
}

sub isfocusedform {
   my $self      = shift;
   my $isfocused = $self->thisform();
   return 1 if ( ref($self) eq ref($isfocused) );
   return 0;
}

sub isfocusedwidget {
   my $self      = shift;
   my $isfocused = $self->thiswidget();
   return 1 if ( ref($self) eq ref($isfocused) );
   return 0;
}

1;
