package Pdt::Form::Display;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: This is the display controller for a block of forms

use Pdt::O qw(:all);
use Pdt::Form;
our @ISA = qw(Pdt::Form);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Display->newdisplay(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newform {
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

