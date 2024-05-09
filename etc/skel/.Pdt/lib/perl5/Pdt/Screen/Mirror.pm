package Pdt::Screen::Mirror;    # (P: o) EXPORTONLY

#: Mirror is a 2d array that is used to keep track of
#: character positions in forms in the event of popups
#: or movement.

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
   my ( $tcol, $trow ) = Term::Size::Unix::chars * STDOUT { IO };

   for ( my $r = 0 ; $r < $trow ; $r++ ) {
      $self->[ $r ] = [];
      for ( my $c = 0 ; $c < $tcol ; $c++ ) {
         $self->[ $r ]->[ $c ] = " ";
      }
   }

   return $self;
}

1;
