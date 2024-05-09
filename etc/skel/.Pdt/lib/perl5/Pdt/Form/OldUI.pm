package Pdt::Form::UI;    # EXPORTONLY (:P x)

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: User Interface class functions for use with Pdt Forms

use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(myform registerfocus registertemplate registerui setsig_redrawform thisform thiswidget);                          # (:C cbexport)
our %EXPORT_TAGS = ( 'all' => [ qw(myform registerfocus registertemplate registerui setsig_redrawform thisform thiswidget) ] );    # (:C cbexport)

use strict;

### startup registrations

# the forms and widgets have the opportunity to intercept focus
# registration so that they may choose not to register certain components.
# though typically they just dump themselfs into the focus table.
# focus table registration needs to occur whenever a form comes into
# focus. The table has an delete/add cycle so that add and removal
# of pages can be reasonably accomidated.

sub registerfocus {    # walk the template, and update the focus table (goes in Ucll, to later go to Pdt::Form::UI)
   my $self = shift;

   # if GEOM is not showing up here, you may have pranged Pdt::Form::Factory.

   bonk "UI", "UI registerfocus: ", $self->{'TEMPLATE'}, " ", $self->{'TEMPLATE'}->{'GEOM'};

   $self->{'TEMPLATE'}->{'GEOM'}->{'FORM'}->registerfocus();

   my $wcount = 0;

   foreach my $w ( keys( %{ $self->{'TEMPLATE'}->{'GEOM'}->{'WIDGET'} } ) ) {
      $self->{'TEMPLATE'}->{'GEOM'}->{'WIDGET'}->{$w}->registerfocus();
      $wcount++;
   }

   return $wcount;
}

# the forms and widgets define default keymap parameters by means of overlapping
# keyset() definitions. (see M: keyset, M: keyadd) The table has a delete/add
# cycle for forms. So that key dispatch can be modified (disabled widgets for
# example)

sub registertemplate {    #
   my $self = shift;

   bonk "UI", "UI begin collating template from factory: ", $self->{'TEMPLATEF'};

   return undef unless ( defined( $self->{'TEMPLATEF'} ) );    # template factory

   # Here, the template factory  TEMPLATEF compares the UI object last token name to
   # to the template last token name, and if the same, loads the object into
   #

   ${ $self->{'TEMPLATEF'} }->cbcollate( $self, 'TEMPLATE', @_ );

   bonk "UI", "UI collated template: ", $self->{'TEMPLATE'};

   return $self->{'TEMPLATE'};
}

sub registerquery {    # collate our most related database table class into the ui object

#   my $self = shift;
#
#   bonk "UI", "UI begin collating template from factory: ", $self->{'TEMPLATEF'};
#
#   return undef unless ( defined( $self->{'TEMPLATEF'} ) );    # template factory
#
#   # Here, the template factory  TEMPLATEF compares the UI object last token name to
#   # to the template last token name, and if the same, loads the object into
#   #
#
#   ${ $self->{'TEMPLATEF'} }->cbcollate( $self, 'TEMPLATE', @_ );
#
#   bonk "UI", "UI collated template: ", $self->{'TEMPLATE'};
#
#   return $self->{'TEMPLATE'};
}

sub registerui {    # (:M setget)
   my $self = shift;

   bonk "UI", "UI initiating UI registration";
   bonk "UI", "UI template:  ", $self->{'TEMPLATE'}, ":", $self->{'TEMPLATE'}->{'GEOM'};

   $self->registertemplate();    # collate the template
   $self->registerquery();       # collate the database handle

   bonk "UI", "UI registerui geom: ", $self->{'GEOM'};

   $self->registerfocus();       # populate the focus table

   return ();
}

#### CURRENT FOCUS

# these gets the currently focused objects, which may not correlate
# to this UI. This can be used to detect shifts.

sub thisform {                   # just get the form object (working)
   my $self = shift;
   return undef unless defined $self->{'TEMPLATE'};
   return ( $self->{'TEMPLATE'}->{'GEOM'}->thisform(@_) );
}

sub thiswidget {                 # just get the form object
   my $self = shift;
   return undef unless defined $self->{'TEMPLATE'};
   return ( $self->{'TEMPLATE'}->{'GEOM'}->thiswidget(@_) );
}

sub setsig_redrawform {          # bind a block of events to sigwinch, run them, and refocus.
   my $self = shift;

   bonk 'UI', "UI ", $self->{'TEMPLATE'}, " ", $self->{'GEOM'}->{'SIGNAL'};
   $self->{'TEMPLATE'}->{'GEOM'}->{'SIGNAL'}->setsigque( 'WINCH', @_ );    # set the window change events

   return ();
}

#### SHORTCUTS

sub myform {                                                               # the form assosciated with this UI regardless of focus
   return $_[ 0 ]->{'TEMPLATE'}->{'GEOM'}->{'FORM'};
}

1;
