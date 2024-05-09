package Pdt::Form::Keyset;    # EXPORTONLY (:P x)

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: uniform key dispatch recursion functions

use Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw(keyadd KEYSET);                     # (:C cbexport)
our %EXPORT_TAGS = ( 'all' => [ qw(keyadd KEYSET) ] );    # (:C cbexport)

use strict;

# this goes into Pdt::Form::Keytable Pdt::Form::Form Pdt::Form::Widget Pdt::Form::<widgettype>
# and should be redefined locally using the macro. This is just a catch-all

sub KEYSET {                                              # (:M keyset)
   my $self = shift;

   unless ( defined $self->{'KEYSET'} ) {
      $self->{'KEYSET'} = {

         # keyset data
      };
   }

   return $self->{'KEYSET'};
}

# this goes into Pdt::Form::Keytable Pdt::Form::Form Pdt::Form::Widget
# allowing users to update key dispatch at any level

sub keyadd {    # overlay user defined keys into the form
   my $self    = shift;
   my $keyhash = shift;

   unless ( defined $self->{'KEYSET'} ) {
      $self->{'KEYSET'} = {};
   }

   if ( ref($keyhash) eq 'HASH' ) {
      foreach my $k ( keys(%$keyhash) ) {
         $self->{'KEYSET'}->{$k} = delete( $keyhash->{$k} );
      }
   }

   return $self->{'KEYSET'};
}

1;
