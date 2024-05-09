package Dpdt::Clock;    # (P: o)

#: time calculation functions for diffing report files left by pdt

use Pdt::O qw(:all);
use Dpdt;
our @ISA = qw(Dpdt);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Dpdt::Clock->newdpdt(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newdpdt {
   my $class = shift;

   # my %OPT = @_ ;

   my ( $self, $start ) = AUTOLITH($class);    # monolithic object
                                               # my ($self, $start) = PLUROLITH($class) ; # record style object

   # take out anything that shouldn't get autoprocessed.
   # $self->{'FOO'} = delete $OPT{'FOO'} if exists $OPT{'FOO'} ;

   if ($start) {    # A, true only on first run. P, always true

      # uncomment to enable callbacks
      # $self->cbmap() ; # create with C: cbmap

      # set defaults here

   } else {

      # runtime completeness checks

   }

   # anything not yet deleted autowrites to properties
   # $self->AUTOPOPULATE(%OPT) ;

   # anything not yet deleted autoexecutes to methods, OR autowrites properties
   $self->AUTOMAP(@_);

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.)
# sub cbmap { }

### METHODS

# :M <yourmethod> (build methods from templates)

1;

