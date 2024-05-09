package Pdt::Method_KeySet;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

__DATA__
sub KEYSET {    # (:M keyset)
   my $self = shift;

   unless ( defined $self->{'KEYSET'} ) {

		# uncomment for derived widgets and forms, delete for templates 
      # $self->SUPER::KEYSET(@_);

      $self->keyadd({
<TMPL_VAR NAME=keyset_entry>		});
   }

   return $self->{'KEYSET'};
}
