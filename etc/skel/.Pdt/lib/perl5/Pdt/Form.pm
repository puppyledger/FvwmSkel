package Pdt::Form;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

#  deprecated and replaced with Pdt::Form:API

use Pdt::O qw(:all);
use Pdt::Form::Factory;
use Pdt::Form::API qw(:all);

use Pdt::Form::Window;    # property container
use Pdt::Form::Form;      #
use Pdt::Form::Widget;    #

use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);

our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

sub new { # 
   my $class     = shift;
   my %formparam = @_;

   # We are called by a frame classes _init function. It passes us params
   # for configuring everything about a given form. We are a plurolistic
   # class, as there may be

   my ( $self, $start ) = PLUROLITH($class);    # object registration

   # sets: SCREEN, FOCUS, PDTAPI, SIGNAL, KEYMAP

   $self->initapi();                            # load our API dependencies

   # set our local callbacks

   $self->cbmap();                              # load our callbacks

   # sets: FRAME, FORM, WIDGET, TEMPLATE, from %GEOM.

   $self->AUTOPOPULATE(%formparam);

   # NOTE: ALIGN used to bind the form alignment property here, this still
   # needs to be pushed to Pdt::Form::Form

   my $widgethash = {};

   foreach my $k ( keys %{$widgethash} ) {

      # here we map the the template scalar which is used to contain the actual value
      # into the passed hash data prior to assimilating it into a real widget.

      # $widgethash->{$k}->{'fvalue'} = \$template->{ $widgethash->{$k}->{'ffullname'} };

      # then construct the widget with all the master objects and the widgets specific
      # parameters.

      $self->{'WIDGET'}->{$k} = Pdt::Form::Widget->newwidget( %$self, %{ $widgethash->{$k} } );
   }

   # then we page back in our callback maps.

   # $self->{'cbmap'} = $reservecbmap;

   # Then we backload the widgets into the form

   $self->{'FORM'}->{'WIDGET'} = $self->{'WIDGET'};

   return $self;
}

### CALLBACKS

# Pdt::Form::Place

# NOTE: KEYSET() and keyadd() have to be added manually.

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'firstwidget'}      = sub { shift; return $self->firstwidget(@_); };
   $self->{'cbmap'}->{'focuswidget'}      = sub { shift; return $self->focuswidget(@_); };
   $self->{'cbmap'}->{'thisform'}         = sub { shift; return $self->thisform(@_); };
   $self->{'cbmap'}->{'thiswidget'}       = sub { shift; return $self->thiswidget(@_); };
   $self->{'cbmap'}->{'unfocusallwidget'} = sub { shift; return $self->unfocusallwidget(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

#### UTILITY

#### CONTAINERS

#: FORM() and WIDGET() set/gets, retrieve the current FORM object, and
#: WIDGET object array containing all of the widgets within the form.
#: These are the respective objects that derive from the templates
#: configuration parameters.

#
#sub FORM { # (:M setget)
#   my $self = shift;
#   $self->{'FORM'} = $_[ 0 ] if defined $_[ 0 ];
#   return $self->{'FORM'};
#}
#
#sub WIDGET { # (:M setget)
#   my $self = shift;
#   $self->{'WIDGET'} = $_[ 0 ] if defined $_[ 0 ];
#   return $self->{'WIDGET'};
#}
#
##### HOUSEKEEPING
#
## moved to Pdt::Form::API
#
##sub clearform {    # soft reset all fields, and homewidget
##   my $self = shift;
##   my $F    = $self->{'FOCUS'}->thisform();
##   return ( $F->clearform() );
##}
#
##### DATABASE TRANSLITERATION
#
#sub hash2form { # the query provides a hash, which is autodispatched to the form (done)
#   my $self   = shift;
#   my %record = @_;
#
#   unless ( scalar(@_) ) {
#      bonk "FORM", "FORM hash2form recieved no record";
#      return ();
#   }
#
#   my @OVQ;        #outbound event que
#
#   my $T = $self->{'FRAME'};
#   my $F = $self->{'FORM'};
#
#   my @f = $T->fields();
#
#   # clear the properties, don't redraw
#
#   if ( ref( $F->{'cbmap'}->{'clearform'} ) eq 'CODE' ) {
#      push @OVQ, newevent( undef, $F, undef, $F->{'cbmap'}->{'clearform'}, 0 );
#   }
#
#   foreach my $k (@f) {
#      if ( defined $T->{'cbmap'}->{$k} ) {
#         my $value = delete $record{$k};
#         my $thiscb = sub { &{ $T->{'cbmap'}->{$k} }($value); };
#         push @OVQ, newevent( undef, $self->{'FORM'}, undef, undef, $thiscb, 0, \%record );
#      } else {
#
#         # HERE <--------------- This needs to be updated to reach into the focus registered table
#         # look up the flongname, for the current fname and write the value
#      }
#   }
#
#   push @OVQ, newevent( undef, $self->{'FORM'}, undef, $self->{'FORM'}->{'cbmap'}->{'recordupdate'}, 0, \%record );
#
#   push @OVQ, $self->homewidget();
#
#   $OVQ[ $#OVQ ]->redraw(1);    # set the redraw flag on the last event
#
#   return @OVQ;
#}
#
#sub form2hash { # get a hash from the values in the form (done)
#   my $self = shift;
#
#   my %record;
#
#   my $T = $self->{'FRAME'};
#   my @f = $T->fields();
#
#   foreach my $k (@f) {
#      $record{$k} = ${ $self->{'WIDGET'}->{$k}->{'fvalue'} };
#   }
#
#   return %record;
#}
#
##### KEYMAP
#
## These have been externalized to Pdt::Form::API
#
#sub bindkeymap {    #
#   my $self = shift;
#
#   # since keybindings can potentially be modified during runtime,
#   # we call KEYSET here. This does nothing in most circumstances.
#
#   my $thiswidget = $self->thiswidget();
#   $thiswidget->KEYSET();
#
#   bonk "FORM", "\tFORM ------- BINDKEYMAP -----------";
#   bonk "FORM", "\t\tself keymap: $self $self->{'KEYMAP'}";
#   bonk "FORM", "\t\tself thiswidget: $self ", $thiswidget;
#
#   # KEYMAP->bindkeymap cascades the current form template and widget
#
#   $self->{'KEYMAP'}->bindkeymap();
#}
#
#sub unbindkeymap {
#   my $self = shift;
#   bonk "FORM", "\tFORM ------- UNBINDKEYMAP -----------";
#   $self->{'KEYMAP'}->unbindkeymap();
#}

##### FOCUS
#
# these methods are derived into both Pdt::Form::Form and Pdt::Form::Widget
# and should provide the neccessary utility to function for both, and in
# most derived cases.

# these are now in Pdt::Form::API

sub thisform { # 
   my $self = shift;
   return ( $self->{'FOCUS'}->thisform() );
}

sub thiswidget { # 
   my $self = shift;
   return ( $self->{'FOCUS'}->thiswidget() );
}

sub firstwidget { # 
   my $self = shift;
   return ( $self->{'FOCUS'}->firstwidget() );
}

sub focuswidget { # provide name, get event / provide nothing, get name (done)
   my $self  = shift;
   my $fname = shift;

   my $fwidget;
   my $event = [];

   if ( length($fname) ) {    #
      if ( defined $self->{'WIDGET'}->{$fname} ) {
         $self->unfocusallwidget();
         $self->{'WIDGET'}->{$fname}->{'ffocus'} = 1;
         $fwidget = $self->{'WIDGET'}->{$fname};
         $event = [ undef, $self->{'FORM'}, $fwidget, $fwidget->{'cbmap'}->{'takefocus'}, undef, @_ ];
      } else {
         bonk "FORM: focus requested for undefined widget: ", $fname;
      }
   } else {                   #
      foreach my $k ( keys %{ $self->{'WIDGET'} } ) {
         if ( $self->{'WIDGET'}->{$k}->{'ffocus'} ) {
            $fwidget = $self->{'WIDGET'}->{$k};
            last;
         }
      }
   }

   return ($event) if scalar(@$event);
   return $fwidget->{'fname'} if defined $fwidget;
   return ();
}

sub unfocusallwidget { # zeros the focus state for all widgets (done)
   my $self = shift;

   foreach my $k ( keys %{ $self->{'WIDGET'} } ) {
      $self->{'WIDGET'}->{$k}->{'ffocus'} = 0;
   }

   return ();
}

#sub focusfirst { # focus the first widget in the form
#   my $self = shift;
#
#   my $oldwidget = $self->{'FOCUS'}->thiswidget();
#   my $newwidget = $self->{'FOCUS'}->firstwidget();
#
#   $oldwidget->dropfocus() if ( defined $oldwidget );
#   $newwidget->takefocus();
#
#   my $haschanged = $self->{'FOCUS'}->thiswidget();
#
#   bonk "FORM", "\t\tFOCUSNEXT $oldwidget $newwidget $haschanged";
#
#   $self->placefocus();
#}
#
#sub focusprev { # focus the prev widget in the form
#   my $self = shift;
#
#   # this thinks that focus should circular loop the widgets:
#
#   my $oldwidget = $self->{'FOCUS'}->thiswidget();
#   my $newwidget = $self->{'FOCUS'}->prevwidget();
#
#   $oldwidget->dropfocus() if ( defined $oldwidget );
#   $newwidget->takefocus();
#
#   my $haschanged = $self->{'FOCUS'}->thiswidget();
#
#   bonk "FORM", "\t\tFOCUSNEXT $oldwidget $newwidget $haschanged";
#
#   $self->placefocus();
#}
#
#sub focusnext { # focus the next widget in the form
#   my $self = shift;
#
#   bonk "FORM", "\tFORM FOCUS NEXT";
#
#   my $oldwidget = $self->{'FOCUS'}->thiswidget();
#   my $newwidget = $self->{'FOCUS'}->nextwidget();
#
#   $oldwidget->dropfocus() if ( defined $oldwidget );
#   $newwidget->takefocus();
#
#   my $haschanged = $self->{'FOCUS'}->thiswidget();
#
#   bonk "FORM", "\t\tFOCUSNEXT $oldwidget $newwidget $haschanged";
#
#   $self->placefocus();
#}
#
#sub takefocus { #
#   my $self = shift;
#   bonk "WIDGET", "TAKING FOCUS $self";
#   $self->{'FOCUS'}->thiswidget($self);
#   $self->bindkeymap();    # Pdt::Form::bindkeymap
#   return ();
#}
#
#sub dropfocus { #
#   my $self = shift;
#   bonk "WIDGET", "DROPPING FOCUS $self";
#   $self->unbindkeymap();    # Pdt::Form::unbindkeymap
#   return ();
#}
#
#sub homewidget { # The "home" widget, is the lowest focusorder widget (done)
#   my $self   = shift;
#   my $worder = [];
#
#   # the widgets know what order they are in and if they
#   # are disabled. So we make an ordered list of only
#   # enabled widgets.
#
#   my $F = $self->{'FOCUS'}->thisform();
#
#   foreach my $k ( keys( %{ $F->{'WIDGET'} } ) ) {
#      my $ffocusorder = $F->{'WIDGET'}->{$k}->{'ffocusorder'};
#      my $fdisable    = $F->{'WIDGET'}->{$k}->{'fdisable'};
#      $worder->[ $ffocusorder ] = $k unless $fdisable;
#   }
#
#   # then we pick the first one.
#
#   my $homewidget;
#
#   foreach (@$worder) {
#      if ( length($_) ) {
#         $homewidget = $F->{'WIDGET'}->{$_};
#         last;
#      }
#   }
#
#   my $event = newevent( undef, $F->{'FORM'}, $homewidget, undef, $homewidget->{'cbmap'}->{'takefocus'}, undef, @_ );
#
#   return $event;
#}
#
##### MISC
#
#sub bell { # my $self = shift;
#   bonk 'FORM', "FORM system bell not yet implemented.";
#}
#

1;
