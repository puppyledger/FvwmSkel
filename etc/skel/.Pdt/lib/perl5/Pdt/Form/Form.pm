package Pdt::Form::Form;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-22.10-27-44.EDT';

# #
my $VERSION = '2018-04-22.10-13-07.EDT';

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#:
#: Property container for FORM attributes
#:

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Pdt::Form::API;
use Pdt::Form::Event qw(:all);
use Pdt::Form::Align;
use Data::Dumper qw(Dumper);

our @ISA = qw(Pdt::Form::API);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Form->newform(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newform { # 
   my $class = shift;
   my %opt   = @_;

   my ( $self, $start ) = PLUROLITH($class);    # object registration

   $self->initapi();
   $self->cbmap();                              # create a method map
   $self->keyset();

   $self->{'ALIGN'} = Pdt::Form::Align->new();

   bonk "FORM", "\tform alignment object: ", $self->{'ALIGN'};

   # Note: Factory attributes are automapped in at new(),
   # and widget attributes are called by Pdt::Form later
   # to inject in the hash attributes that constitute the
   # form.

   # this should hit ALIGN with the respective form params.

   $self->AUTOMAP(%opt);

   return $self;
}

# this may get called non-oo to attempt to derive some basic form params
# from a parent frame. Note that this should be changed if the output of
# M: formmap changes.

sub defaultparam { # default form parameters if not defined
   my $F = shift;
   my $f = {};
   $f->{'NAME'}        = $F->lowercaselasttoken();
   $f->{'FORMNAME'}    = $F->lowercaselasttoken();
   $f->{'COL'}         = 0;
   $f->{'ROW'}         = 0;
   $f->{'FORMORDER'}   = 0;
   $f->{'ALIGN'}       = [ 'place', $f->{'COL'}, $f->{'ROW'} ];
   $f->{'REPLACEMODE'} = 0;
   return $f;
}

### CALLBACKS

# Pdt::Form Pdt::Form::Place

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'ALIGN'}         = sub { shift; return $self->ALIGN(@_); };
   $self->{'cbmap'}->{'align'}         = sub { shift; return $self->align(@_); };
   $self->{'cbmap'}->{'clearform'}     = sub { shift; return $self->clearform(@_); };
   $self->{'cbmap'}->{'COL'}           = sub { shift; return $self->COL(@_); };
   $self->{'cbmap'}->{'defaultparam'}  = sub { shift; return $self->defaultparam(@_); };
   $self->{'cbmap'}->{'draw'}          = sub { shift; return $self->draw(@_); };
   $self->{'cbmap'}->{'drawblank'}     = sub { shift; return $self->drawblank(@_); };
   $self->{'cbmap'}->{'drawfocus'}     = sub { shift; return $self->drawfocus(@_); };
   $self->{'cbmap'}->{'drawformfocus'} = sub { shift; return $self->drawformfocus(@_); };
   $self->{'cbmap'}->{'dropfocus'}     = sub { shift; return $self->dropfocus(@_); };
   $self->{'cbmap'}->{'focusnext'}     = sub { shift; return $self->focusnext(@_); };
   $self->{'cbmap'}->{'focusprev'}     = sub { shift; return $self->focusprev(@_); };
   $self->{'cbmap'}->{'FORMFOCUS'}     = sub { shift; return $self->FORMFOCUS(@_); };
   $self->{'cbmap'}->{'FORMNAME'}      = sub { shift; return $self->FORMNAME(@_); };
   $self->{'cbmap'}->{'FORMORDER'}     = sub { shift; return $self->FORMORDER(@_); };
   $self->{'cbmap'}->{'isfocused'}     = sub { shift; return $self->isfocused(@_); };
   $self->{'cbmap'}->{'KEYSET'}        = sub { shift; return $self->KEYSET(@_); };
   $self->{'cbmap'}->{'NAME'}          = sub { shift; return $self->NAME(@_); };
   $self->{'cbmap'}->{'PARENTFRAME'}   = sub { shift; return $self->PARENTFRAME(@_); };
   $self->{'cbmap'}->{'ROW'}           = sub { shift; return $self->ROW(@_); };
   $self->{'cbmap'}->{'takefocus'}     = sub { shift; return $self->takefocus(@_); };
   $self->{'cbmap'}->{'winch'}         = sub { shift; return $self->winch(@_); };

   return ( $self->{'cbmap'} );
}

#### PDT::Form::API

# these functions are polymorphic

sub isfocused {
   my $self = shift;
   return ( $self->isfocusedform(@_) );
}

sub dropfocus {
   my $self = shift;
   return ( $self->dropformfocus(@_) );
}

sub takefocus {
   my $self = shift;
   return ( $self->takeformfocus(@_) );
}

sub focusnext {
   my $self = shift;
   return ( $self->focusnextform(@_) );
}

sub focusprev {
   my $self = shift;
   return ( &focusprevform(@_) );
}

#### DRAWING

# at the form level, we find the geometry of the form, and draw over
# that space in blanks.

sub drawblank {
   my $self = shift;

   bonk "FORM", "\twiping form: ", $self->NAME(), " ", $self;

   $self->wipeform();    # Pdt::Form::Place

   return ();
}

sub draw { # draw a form object
   my $self = shift;

   bonk "FORM", "\tplacing form: ", $self->NAME(), " ", $self;

   $self->placeform();

   return ();
}

#### ALIGNMENT

# ALIGN is called with: (<alignmenttype>, COL, ROW) and will aways
# set to (offsetx, offsety) which reflects the terminal offset from
# top left.

sub ALIGN { # boot time loadage, or get.
   my $self  = shift;
   my @param = @_;

   bonk "FORM", "FORM INITIAL ALIGNMENT REQUEST: ", @param;

   unless ( ref( $self->{'ALIGN'} ) eq 'Pdt::Form::Align' ) {
      $self->{'ALIGN'} = Pdt::Form::Align->new();
   }

   # the alignment for any object, is the actual character offset
   # required to begin rendering it. to accomplish this we need
   # the dimensions of the object, the character offset of the
   # parent object if any, and the calculation method for the
   # inner alignment, and the requested offset parameters to
   # be supplied to that calc method if any.

   $self->{'ALIGN'}->alignform(
      'width'  => $self->{'COL'},
      'height' => $self->{'ROW'},
      'sos_x'  => 0,
      'sos_y'  => 0,
      'align'  => $param[ 0 ],
      'x'      => $param[ 1 ],
      'y'      => $param[ 2 ]
   );

   return ( @{ $self->{'ALIGN'} } );
}

sub align { &ALIGN(@_); }

#### DRAWING

sub drawformfocus { # place the focus where it wants to be
   my $self = shift;
   bonk "FORM", "FORMFORM drawofocus";
   $self->placefocus();
   return ();
}

sub drawfocus { return ( &drawformfocus(@_) ); }

#### BULK WIDGET METHODS

sub clearform { # soft form clear and home widget
   my $self = shift;

   # here we use the order in focusorder, to walk the widgets, create
   # events that clear them indevidually, and then home the widget to
   # the lowest focus position.

   my @OVQ;

   foreach my $W ( @{ $self->{'FOCUS'}->{'FORMTABLE'}->{ $self->{'NAME'} }->{'FOCUSORDER'} } ) {
      if ( defined $W ) {
         if ( defined $W->{'cbmap'} ) {
            if ( defined $W->{'cbmap'}->{'place2del'} ) {
               push @OVQ, newevent( undef, $self, $W, undef, $W->{'cbmap'}->{'place2del'}, undef, @_ );
            }
         }
      }
   }

   push @OVQ, $self->homewidget();    #

   return @OVQ;
}

# hash2form is now inherited

# form2hash now inherited

# homewidget is now inherited

#### KEYSET

sub KEYSET { # (:M keyset)
   my $self = shift;

   unless ( defined $self->{'KEYSET'} ) {

      $self->keyadd(
         {
            '22' => $self->{'cbmap'}->{'focusnext'}    # placeholder, delete me
         }
      );

   }

   return $self->{'KEYSET'};
}

### SIGNALS

sub winch { # return the data in the winch callback
   return &{ $_[ 0 ]->{'WINCH'} };
}

#### GENERIC SET/GET

sub COL { # colcount of the characters in the template
   my $self = shift;
   $self->{'COL'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'COL'};
}

sub FORMFOCUS { # (:M setget)
   my $self = shift;
   $self->{'FORMFOCUS'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'FORMFOCUS'};
}

sub FORMORDER { # (:M setget)
   my $self = shift;
   $self->{'FORMORDER'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'FORMORDER'};
}

sub NAME { # (:M setget)
   my $self = shift;
   $self->{'NAME'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'NAME'};
}

# forms are always named the same as their parent frame

sub FORMNAME { # (:M setget)
   my $self = shift;

   my $F = $self->PARENTFRAME();

   if ( defined $F ) {
      $self->{'FORMNAME'} = $F->FRAMENAME();
      return $self->{'FORMNAME'};
   }

   return undef;
}

sub PARENTFRAME { # (:M setget)
   my $self = shift;
   $self->{'PARENTFRAME'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'PARENTFRAME'};
}

sub ROW { # rowcount of characters in the template
   my $self = shift;
   $self->{'ROW'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'ROW'};
}

sub TEMPLATE { # (:M setget)
   my $self = shift;

   my $P = $self->PARENTFRAME();

   if ( defined $P ) {
      return $P->TEMPLATE();
   }

   return ();
}

1;
