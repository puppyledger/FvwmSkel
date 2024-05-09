package Pdt::Term::Minicom;    # (P: o)

#: Minicom Port TTY IO handle controller

use Pdt::O qw(:all);
use Pdt::Term;
our @ISA = qw(Pdt::Term);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Term::Minicom->newterm(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newterm {
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   $self->AUTOPOPULATE(@_);

   # map our exportable functions

   if ($start) {

      # statics

      # $self->cbmap() ; # create a method map

   } else {

      # runtime completeness checks

   }

   # stack cleanup

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.)

# sub cbmap { }

### METHODS

# :M <yourmethod> (build methods from templates)

1;

