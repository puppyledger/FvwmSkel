package Pdt::Form::Focus::Widget;    # (P: o)

#: Widget Focus Table

use Pdt::O qw(:all);
use Pdt::Form::Focus;
our @ISA = qw(Pdt::Form::Focus);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Focus::Widget->newfocus(@_); }

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
   $self->{'cbmap'}->{'addwidget'}  = sub { shift; return $self->addwidget(@_); };
   $self->{'cbmap'}->{'byname'}     = sub { shift; return $self->byname(@_); };
   $self->{'cbmap'}->{'current'}    = sub { shift; return $self->current(@_); };
   $self->{'cbmap'}->{'delwidget'}  = sub { shift; return $self->delwidget(@_); };
   $self->{'cbmap'}->{'lastwidget'} = sub { shift; return $self->lastwidget(@_); };
   $self->{'cbmap'}->{'nextwidget'} = sub { shift; return $self->nextwidget(@_); };

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

sub addwidget {    # set/get
   my $self = shift;
   $self->{'addwidget'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'addwidget'};
}

sub delwidget {    # set/get
   my $self = shift;
   $self->{'delwidget'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'delwidget'};
}

sub nextwidget {    # set/get
   my $self = shift;
   $self->{'nextwidget'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'nextwidget'};
}

sub lastwidget {    # set/get
   my $self = shift;
   $self->{'lastwidget'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'lastwidget'};
}

1;

