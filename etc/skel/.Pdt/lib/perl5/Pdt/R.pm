package Pdt::R;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

# This is deprecated, and has been replaced by an updated AUTOLITH
# function in Pdt::O. Expect this file to be deleted in future
# version.

use Exporter;
our @ISA    = qw(Exporter);
our @EXPORT = qw(REGISTER REGISTRY GETREGISTERED);

use strict;

sub REGISTER { # Register an object if we can
   my $self = shift;
   return undef unless defined $::REGISTRY;

   my $class = $self;
   my @foo = split( /\=/, $class );

   # we've previously been blessed,  so we should already be registered.

   return ( $foo[ 0 ] ) if ( scalar(@foo) > 1 );

   $class = $foo[ 0 ];

   $::REGISTRY->{$class} = $self unless scalar(@_);    # REGISTER($obj) or $self->REGISTER()  registers by class
   $::REGISTRY->{ $_[ 0 ] } = $self if scalar(@_);     # REGISTER($obj, 'foo') or $self->REGISTER('foo') registers by name

   return $class;
}

sub REGISTRY { # return the REGISTRY if it exists
   return undef unless defined $::REGISTRY;
   return ($::REGISTRY);
}

sub GETREGISTERED { # get an object by naming the class
   return $::REGISTRY->{ $_[ 1 ] } if ( defined( $::REGISTRY->{ $_[ 1 ] } ) );    # (self, class)
   return undef;
}

1;
