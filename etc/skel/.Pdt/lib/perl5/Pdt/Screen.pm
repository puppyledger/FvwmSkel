package Pdt::Screen;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

# There is some POSIX stuff in Pdt::Term::*
# that can probably go here to catch escapes.

use Pdt::O qw(:all);
use Term::Screen;
use Term::Size::Unix;

use Pdt::Bonk qw(:all);
use Data::Dumper;

our @ISA = qw(Term::Screen);

# this breaks things
# our @ISA = qw(Term::Screen Pdt::O);

use strict;

sub new {    #
   my $class = shift;
   my $self  = Term::Screen->new();
   bless $self, $class;
   return $self;
}

1;
