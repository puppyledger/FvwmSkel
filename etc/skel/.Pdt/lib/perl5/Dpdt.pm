package Dpdt;    # (P: r)

#: diff pdt root class

use Base::O;
use Dpdt::Factory;
our @ISA = qw(Base::O);

use strict;

our $__API__;

$::_DEBUGAUTOLOAD = 0;    # trace bad function calls that puke in Pdt::O

### CONSTRUCTORS

# calling new() on a root class returns the factory for all of its objects.

sub new {
   shift;
   my $F = Dpdt::Factory->new(@_);
   my $A = $F->api();
   bless $A, "Dpdt";
   $Dpdt::__API__ = $A;    # store for setgets
   return $A;
}

# get for the whole API handle.

sub newdpdtapi { # 
   return (Dpdt::__API__);
}

### SETGET (:M apiget Dpdt Dpdt::Factory) # autogen accessors

1;

