package Pdt::Term;    # (P: r)

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

#: Pdt Terminal IO handle controllers, root class

use Pdt::O;
use Pdt::Term::Factory;
our @ISA = qw(Pdt::O);

use strict;

$::_DEBUGAUTOLOAD = 0;    # trace bad function calls that puke in Pdt::O

### CONSTRUCTORS

# calling new() on a root class returns the factory for all of its objects.

sub new { shift; Pdt::Term::Factory->new(@_); }

# this is the common constructor for your API. Below is just a stub.
# this constructor should be redefined in any class that derives
# from this class.

sub newterm {             # STUB ONLY.

   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   $self->AUTOPOPULATE(@_);

   # map our exportable functions

   if ($start) {

      # $self->cbmap() ; # initialize callback table

   } else {

      # runtime completeness checks

   }

   # stack cleanup

   return $self;
}

### CALLBACKS

# :C cbmap <additional classes> builds callback map.

# sub cbmap { }

### METHODS

# :M setget <method list> builds methods

1;

