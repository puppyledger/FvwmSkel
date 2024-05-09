package Pdt::Primitive_Frame;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw( $T );
our $T;
use strict;
1;

#: A template that makes templates

# cbenv: insert environment variables into templates without asking questions.

sub cbenv { # Map uppercase ENV variables to lowercase template variables
   my $self = shift;
   my @ev   = qw(login_entry_9_0_16);
   return @ev;
}

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; use Exporter; our @ISA = qw(Exporter); use Pdt::L; use Pdt::Form::API ; use Pdt::Bonk qw(:all) ; use Pdt::Form::Focus ; use Pdt::Form::Frame ; use Pdt::Form::Keymap qw(:keyset) ; push @ISA, qw(Pdt::L); our @EXPORT = qw($T, $GEOM); our $T; use strict ;  

# FIELD FORMAT: <TMPL_VAR NAME=login_entry_9_0_16>
#
# "login" in the fieldname, "entry" is the widget type, 
# "9" is the column offset from left, "0" is the row 
# offset from top, "16" is the width of the field. 
# width may be defined as <col>x<row> if applicable.
#
# USAGE: Below the DATA line, create the text form 
# wyswig using the above field format. Then use 
# the pdt macros below (in bottom to top order) to 
# dynamically generate the geometry and keymap 
# bindings. 

# Current Widget Types: entry, password, checkbox, button 

# (:C cbmap) goes here
# (:M keyset) goes here

my $GEOM = {} ; # geometry container
# (:M formgeom) goes here 

sub _init { # on load we convert the geometry hash to a frame object
   my $self = shift;
   my $geom = $self->GEOM();
   my $frame = Pdt::Form::Frame->new( %$geom, 'TEMPLATE' => $self ) ;
   $geom = $self->GEOM($frame) ;
   return () ; 
}

sub GEOM { # the frame object for this template is held in this static 
   my $self = shift;
   my $newgeom = shift ;
   $GEOM = $newgeom if ( defined ($newgeom) );
   return $GEOM ;
}

1 ; 

__DATA__
# your form goes here
