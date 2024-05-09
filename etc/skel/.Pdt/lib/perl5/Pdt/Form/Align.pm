package Pdt::Form::Align;    # (P: o) EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Alignment is an array that contains the current
#: top left corner index of the object (Form, or Widget)
#: and a type that can be used to flag a prefered
#: placement algorithm for determining that position.

#: Alignment is the property, Placement is the method.
#: Note that both alignment and placement do not return
#: events.

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Term::Size::Unix;
use Data::Dumper qw(Dumper) ; 

our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

sub new { # 
   my $class = shift;
   my ( $self, $start ) = PLUROQUE($class);
   return $self;
}

### CALLBACKS

sub cbindex { # (:C cbindex)
	my $self = shift;
	my $lookup = shift; 

   # callback map, generally run at constructor time only.
   # The cbindex program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

	my $cbindex = {
	'alignform' => sub { shift ; return $self->alignform(@_) ; },
	'alignframe' => sub { shift ; return $self->alignframe(@_) ; },
	'alignwidget' => sub { shift ; return $self->alignwidget(@_) ; },
	'center' => sub { shift ; return $self->center(@_) ; },
	'fixed' => sub { shift ; return $self->fixed(@_) ; },
	'topleft' => sub { shift ; return $self->topleft(@_) ; }
	} ; 

	return ($cbindex->{$lookup}) ;
}

### METHODS

sub alignframe {
	return (&alignform(@_)) ; 
}

sub alignform { # callback dispatcher
   my $self = shift;
	my %param = @_; 

#     'width' => $self->{'COL'},
#      'height' => $self->{'ROW'},
#      'sos_x' => 0, # start offset x 
#      'sos_y' => 0, # start offset y
#      'align' => $param[0], # alignment method
#      'x' => $param[1], # argument x to alignment
#      'y' => $param[2]  # argument y to alignment

   return (@$self) unless length(defined($param{'align'}));

   my $methodcb = $self->cbindex($param{'align'});

   if ( ref($methodcb) eq 'CODE' ) {    #

      my @acb = &{$methodcb}( $self, %param );    # acb should be the same as @$self

      return @$self;

   } else {
   	bonk "ALIGN", "\tALIGN no alignment of that type found. We take type,colwidth,rowheight";
	}

   return (@$self);
}

sub alignwidget {
	my $self = shift ; 
}

sub topleft { # should work with forms or widgets
	my $self = shift ; 
	my %param = @_ ; 	

	$self->[0] = "topleft" ; 
	$self->[1] = $param{'sos_x'} + 0 ; 
	$self->[2] = $param{'sos_y'} + 0 ; 

	return (@$self) ; 
}

# here, we can add a form/widget flag, and redefine 
# the calls based on that, to allow for a uniform
# interface. (TODO) 

sub center { # center of screen, forms only
   my $self      = shift ;
	my %param = @_ ; 

   my ( $tcol, $trow ) = Term::Size::Unix::chars * STDOUT { IO };

   # bonk "ALIGN", "ALIGN ", $fcolcount, " ", $frowcount, " ", $tcol, " ", $trow;

	$self->[0] = 'center'; 
   $self->[ 1 ] = int( ( $tcol - $param{'width'} ) / 2 );
   $self->[ 2 ] = int( ( $trow - $param{'height'} ) / 2 );

   return (@$self);
}

sub fixed { # should work with forms or widgets
   my $self      = shift;
	my %param = @_; 

	$self->[0] = "fixed" ; 
	$self->[1] = $param{'sos_x'} + $param{'x'} ; 
	$self->[2] = $param{'sos_y'} + $param{'y'} ; 

   return (@$self);
}

1;
