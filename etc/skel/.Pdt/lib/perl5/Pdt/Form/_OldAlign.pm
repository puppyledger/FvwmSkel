package Pdt::Form::Align;    # (P: o) EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Alignment is an array, that knows where the appropriate top
#: left corner of a form is for this terminal. (whose size
#: may fluctuate.) parameters may be passed to allow form
#: alignment to be relational.

#: NOTE: Alignment does not return events!

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Term::Size::Unix;

our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

sub new {    #
   my $class = shift;
   my ( $self, $start ) = PLUROQUE($class);
   return $self;
}

### CALLBACKS

sub cbindex {    # (:C cbindex)
   my $self   = shift;
   my $lookup = shift;

   # callback map, generally run at constructor time only.
   # The cbindex program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   my $cbindex = {
      'align'   => sub { shift; return $self->align(@_); },
      'center'  => sub { shift; return $self->center(@_); },
      'fixed'   => sub { shift; return $self->fixed(@_); },
      'topleft' => sub { shift; return $self->topleft(@_); }
   };

   return ( $cbindex->{$lookup} );
}

### METHODS

sub align {    # callback dispatcher
   my $self       = shift;
   my $methodname = shift;
   my $col        = shift;    # colwidth
   my $row        = shift;    # rowheight

   return (@$self) unless length($methodname);

   # a standard alignment request will always provide a (type,col,row, <x>, <y>) format

   bonk "ALIGN", "ALIGN alignment requested: ", $self, " ", $methodname, " ", $col, " ", $row;

   my $methodcb = $self->cbindex($methodname);

   if ( ref($methodcb) eq 'CODE' ) {    #
      my @acb = &{$methodcb}( $self, $col, $row, @_ );    # acb should be the same as @$self
      bonk "ALIGN", "ALIGN callback and return vals:", $methodcb, @acb, " ", @$self;
      return @$self;
   }

   bonk "ALIGN", "ALIGN no alignment of that type found. We take colwidth,rowheight,aligntype ";

   return (@$self);
}

sub topleft {                                             # absolute top left alignment
   $_[ 0 ]->[ 0 ] = 0;
   $_[ 0 ]->[ 1 ] = 0;

   return ( @{ $_[ 0 ] } );
}

sub center {                                              # align the form to render in the center of the screen
   my $self      = shift;
   my $fcolcount = shift;
   my $frowcount = shift;

   my ( $tcol, $trow ) = Term::Size::Unix::chars * STDOUT { IO };

   bonk "ALIGN", "ALIGN ", $fcolcount, " ", $frowcount, " ", $tcol, " ", $trow;

   $self->[ 0 ] = int( ( $tcol - $fcolcount ) / 2 );
   $self->[ 1 ] = int( ( $trow - $frowcount ) / 2 );

   # we don't do negative numbers

   $self->[ 0 ] = 0 unless ( $self->[ 0 ] > 0 );
   $self->[ 1 ] = 0 unless ( $self->[ 1 ] > 0 );

   return (@$self);
}

sub fixed {    # just stick a fixed offset in there
   my $self      = shift;
   my $fcolcount = shift;    # get these out of the way,
   my $frowcount = shift;

   $self->[ 0 ] = shift;     # fixed will provide exactly where it wants us
   $self->[ 1 ] = shift;

   return (@$self);
}

1;
