package Pdt::Term::Factory;    # EXPORTONLY

# generated with macro (:P f)

use Pdt::O qw(:all);
our @ISA = qw(Pdt::O);

use Pdt::Term::Autocomp;
use Pdt::Term::Cli;
use Pdt::Term::Form;
use Pdt::Term::Minicom;

use strict;

sub new {    # bootstrap and register autolithic objects
   my $class = shift;
   my ( $self, $start ) = AUTOLITH($class);
   my $object;    # que-tainer
   if ($start) {

      $object = Pdt::Term::Autocomp->newterm(@_);
      $object = Pdt::Term::Cli->newterm(@_);
      $object = Pdt::Term::Form->newterm(@_);
      $object = Pdt::Term::Minicom->newterm(@_);

   }
   $object = undef;
   return ($self);
}

sub autocomp { my $self = shift; return ( Pdt::Term::Autocomp->newterm(@_) ); }
sub cli      { my $self = shift; return ( Pdt::Term::Cli->newterm(@_) ); }
sub form     { my $self = shift; return ( Pdt::Term::Form->newterm(@_) ); }
sub minicom  { my $self = shift; return ( Pdt::Term::Minicom->newterm(@_) ); }

sub allobject {    # get all of the objects as a keyed hash
   my $self = shift;
   my %O;

   $O{'autocomp'} = $self->autocomp();
   $O{'cli'}      = $self->cli();
   $O{'form'}     = $self->form();
   $O{'minicom'}  = $self->minicom();

   return %O;
}

1;

