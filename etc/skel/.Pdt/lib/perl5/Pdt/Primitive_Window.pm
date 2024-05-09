package Pdt::Primitive_Window;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__
package <TMPL_VAR NAME=a_full_classname>;    # (P: o)

#: <TMPL_VAR NAME=b_class_description>

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Pdt::Form::Window ; 

our @ISA = qw(Pdt::Form::Window);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; <TMPL_VAR NAME=a_full_classname>->newwindow(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newwindow {
   my $class = shift;
   my %OPT   = @_;

   my ( $self, $start ) = AUTOLITH($class) ; # self registering object

   if ($start) { # A, true only on first run. P, always true

      # load the api data structures and objects

      $self->initapi();

      # load locally defined callbacks

      # $self->cbmap();

      # name ourselves

      # $self->WINDOWNAME($self->lowercaselasttoken()) ;

      # set the initial window focus state (only one window can be focused at a time)

      # $self->WINDOWFOCUS(1);

      # set a window focus order, (for wizard style interfaces)

      # $self->WINDOWORDER(0);

      # statically list frames we would like to display in this window.
      # this is the last double colon separated text token, of the frame
      # class, in lowercase. Example: Foo::Bar would use "bar" ;

		# my $fg = qw(<TMPL_VAR NAME=c_lc_list_of_frames_in_this_window>) ; 

      # $self->FRAMEGROUP($fg);

   } else {

      # runtime completeness checks

   }

   $self->AUTOMAP(%OPT);

   return $self;
}

### CALLBACKS (:C cbmap)

### KEYSET (:M keyset)

### EVENT METHODS (:M event)

# typically you write event methods, and then bind 
# those events to the keymaps in KEYSET

1; 
