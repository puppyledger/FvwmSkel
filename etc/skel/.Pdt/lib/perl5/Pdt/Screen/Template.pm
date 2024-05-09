package Pdt::Screen::Template;    # EXPORTONLY (:P x)

#: Template native screen functions

use Exporter;
use Pdt::Bonk qw(:all);
our @ISA         = qw(Exporter);
our @EXPORT      = qw(outputblankform);                     # (:C cbexport)
our %EXPORT_TAGS = ( 'all' => [ qw(outputblankform) ] );    # (:C cbexport)

use strict;

# widgets define an ftext property, which is a default display text.
# typically this is just blank space. When a blank form is requested
# the whole form is processed as a template with the blank text, which
# MUST be the full field in length.

# HTML template checks for code references instead of scalars in field
# data, and executes any if finds for fields that will actually render.
# So we just create a dynamic callback table, and pass that off to
# HTML::Template, and the respective functions just return the ftext
# property instead of the the object value. This should create no

sub outputblankform {
   my $self = shift;

   bonk "TEMPLATE", "TEMPLATE: output blank form";

   return undef unless ( defined $self->{'GEOM'} );

   bonk "TEMPLATE", "\t\tGEOM found";

   return undef unless ( defined $self->{'GEOM'}->{'WIDGET'} );

   bonk "TEMPLATE", "\t\tGEOM WIDGET found";

   my @wk = keys( %{ $self->{'GEOM'}->{'WIDGET'} } );
   my %wbcb;    # blank widget callbacks

   foreach my $k (@wk) {
      my $ffn   = $self->{'GEOM'}->{'WIDGET'}->{$k}->{'ffullname'};
      my $ftext = $self->{'GEOM'}->{'WIDGET'}->{$k}->{'ftext'};
      $wbcb{$ffn} = sub { shift; return $self->{'GEOM'}->{'WIDGET'}->{$k}->{'ftext'}; };
   }

   my $Tref = delete $self->{'__TEMPLATE__'};
   my $t = HTML::Template->new_scalar_ref( $Tref, die_on_bad_params => 0 );

   $t->clear_params();
   $t->param(%wbcb);
   $self->{'__TEMPLATE__'} = $Tref;

   return $t->output();
}

1;
