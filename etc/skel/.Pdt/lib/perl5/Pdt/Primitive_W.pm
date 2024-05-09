package Pdt::Primitive_W;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# Template for widgets.

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; # (P: w)

#: <TMPL_VAR NAME=brief_class_description>

use Pdt::O qw(:all);
use Pdt::Form::Widget;
use <TMPL_VAR NAME=c_widgetclasstoderivefrom>; 
use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);

use Pdt::Form::Place qw(:all);        # cursor placement functions
use Pdt::Form::Event qw(:all);        # event objects
use Pdt::Form::Keymap qw(:keyset);    # keyadd (probably to move to Keymap, and then to Focus)

our @ISA = qw(<TMPL_VAR NAME=c_widgetclasstoderivefrom>);

use strict ; 

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift ; <TMPL_VAR NAME=a_fullpackagename>-><TMPL_VAR NAME=d_api_common_constructor_name>(@_) ; } 

# Our real constructors are name-common only within the API to prevent inheritance collision

sub <TMPL_VAR NAME=d_api_common_constructor_name> { 
   my $class = shift;

   my ( $self, $start ) = PLUROLITH($class);    # object registration

   # interpolate the engines component classes

   # map our exportable functions

   if ($start) {

      # statics

      # $self->cbmap();  # (C: cbmap) 
      # $self->KEYSET(); # (M: keyset) 

   } else {

      # runtime completeness checks

   }

   $self->AUTOMAP(@_);

   # stack cleanup

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.) 
# sub cbmap { }

### METHODS 

# :M <yourmethod> (EXAMPLE:  :M setget foo bar baz)

#### REGISTER

# typically derived widgets register using their 
# parents registration functions. These are totally 
# redundant and can be deleted. 

sub registerfocus { # Pdt::Form::registerfocus
   my $self = shift;
   return ( $self->SUPER::registerfocus(@_) );
}

sub registerkeymap { # Pdt::form::registerkeymap
   my $self = shift;
   return ( $self->SUPER::registerkeymap(@_) );
}

#### FOCUS

# these are all redundant to inherited methods,
# and may be deleted. They are here to demonstrate 
# to hooks. 

sub focusnext { # Pdt::Form::focusnext
   my $self = shift;
   $self->SUPER::focusnext(@_);
   return ();
}

sub focusprev { # Pdt::Form::focusprev
   my $self = shift;
   $self->SUPER::focusprev(@_);
   return ();
}

sub dropfocus { # Pdt::Form::dropfocus
   my $self = shift;
   return ( $self->SUPER::dropfocus(@_) );
}

sub takefocus { # Pdt::Form::takefocus
   my $self = shift;
   return ( $self->SUPER::takefocus(@_) );
}

#### REQUIRED KEY PROCESSING

# these are all redundant to inherited methods,
# and may be deleted. They are here to demonstrate 
# to hooks. 

sub insertchar { # Pdt::Form::Widget
   my $self = shift ;  
   return ( $self->SUPER::insertchar(@_) );
}

sub replacechar { # Pdt::Form::Widget 
   my $self = shift ;  
   return ( $self->SUPER::replacechar(@_) );
}

sub unmappedkey { # Pdt::Form::Widget
   my $self = shift ;  
   return ( $self->SUPER::unmappedkey(@_) );
}

#### OPTIONAL KEY PROCESSING 

# (:M newevent) 

#### KEYDISPATCH

# procedure for custom key bindings. 
#
# 1. write the function that does what you want 
# it to do. 
#
# 2. write the function that references your 
# new function, using (:M newevent()) 
# 
# 3. run (:C cbmap) to generate the localized 
# callback for both functions.  
# 
# 4. run (:M keyset), type the key you want to bind, 
# and then the name of the event generation function 
# that you wrote in (2.).   

sub KEYSET { # (:M keyset)
   my $self = shift;

   unless ( defined $self->{'KEYSET'} ) {

		# uncomment for derived widgets and forms, delete for templates 
      # $self->SUPER::KEYSET(@_);

      $self->keyadd({
		});
   }

   return $self->{'KEYSET'};
}

1 ; 
