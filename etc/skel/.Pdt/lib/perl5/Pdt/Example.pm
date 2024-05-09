package Pdt::Example;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-13.07-03-59.EDT';

#: This is not real application code, it is just a scratch file.

use Pdt::O qw(:all);
use Pdt::o;
our @ISA = qw(Pdt::o);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Example->newexample(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newexample {
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

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'BAR'} = sub { shift; return $self->BAR(@_); };
   $self->{'cbmap'}->{'DAH'} = sub { shift; return $self->DAH(@_); };
   $self->{'cbmap'}->{'DOO'} = sub { shift; return $self->DOO(@_); };
   $self->{'cbmap'}->{'FOO'} = sub { shift; return $self->FOO(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

sub FOO {    # set/get
   my $self = shift;
   $self->{'FOO'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'FOO'};
}

sub BAR {    # set/get
   my $self = shift;
   $self->{'BAR'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'BAR'};
}

sub DOO {    # set/get
   my $self = shift;
   $self->{'DOO'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'DOO'};
}

sub DAH {    # set/get
   my $self = shift;
   $self->{'DAH'} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{'DAH'};
}

1;
