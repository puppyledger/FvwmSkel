package Pdt::Form::Focus::Factory;    # EXPORTONLY

# generated with macro (:P f)

use Pdt::O qw(:all);
our @ISA = qw(Pdt::O);

use Pdt::Form::Focus::Form;
use Pdt::Form::Focus::Widget;

use strict;

sub new {                             # bootstrap and register autolithic objects
   my $class = shift;
   my ( $self, $start ) = AUTOLITH($class);
   my $object;                        # que-tainer
   if ($start) {

      $object = Pdt::Form::Focus::Form->newfocus(@_);
      $object = Pdt::Form::Focus::Widget->newfocus(@_);

   }
   $object = undef;
   return ($self);
}

sub form   { my $self = shift; return ( Pdt::Form::Focus::Form->newfocus(@_) ); }
sub widget { my $self = shift; return ( Pdt::Form::Focus::Widget->newfocus(@_) ); }

sub allobject {    # get all of the objects as a keyed hash
   my $self = shift;
   my %O;

   $O{'form'}   = $self->form();
   $O{'widget'} = $self->widget();

   return %O;
}

1;

