package Pdt::Form::Focus::Form;    # (P: o)

#: Form Focus Table

use Pdt::O qw(:all);
use Pdt::Form::Focus;
our @ISA = qw(Pdt::Form::Focus);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Focus::Form->newfocus(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newfocus {
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   $self->AUTOPOPULATE(@_);

   # map our exportable functions

   if ($start) {

      # statics
      $self->cbmap();                          # create a method map

      $self->{'CURRENT'} = \"";
      $self->{'ORDER'}   = {};
      $self->{'BYNAME'}  = {};

   } else {

      # runtime completeness checks

   }

   # stack cleanup

   return $self;
}

### CALLBACKS

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'addform'}  = sub { shift; return $self->addform(@_); };
   $self->{'cbmap'}->{'byname'}   = sub { shift; return $self->byname(@_); };
   $self->{'cbmap'}->{'current'}  = sub { shift; return $self->current(@_); };
   $self->{'cbmap'}->{'delform'}  = sub { shift; return $self->delform(@_); };
   $self->{'cbmap'}->{'lastform'} = sub { shift; return $self->lastform(@_); };
   $self->{'cbmap'}->{'nextform'} = sub { shift; return $self->nextform(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

sub current {    # set/get
   my $self = shift;
   $self->{'current'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'current'};
}

sub byname {     # set/get
   my $self = shift;
   $self->{'byname'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'byname'};
}

sub addform {    # set/get
   my $self = shift;
   $self->{'addform'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'addform'};
}

sub delform {    # set/get
   my $self = shift;
   $self->{'delform'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'delform'};
}

sub nextform {    # set/get
   my $self = shift;
   $self->{'nextform'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'nextform'};
}

sub lastform {    # set/get
   my $self = shift;
   $self->{'lastform'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'lastform'};
}

1;
