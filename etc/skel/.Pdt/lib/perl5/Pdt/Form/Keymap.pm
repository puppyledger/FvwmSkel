package Pdt::Form::Keymap;    # (P: o) # EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Current Keymap Table

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);
use Pdt::Form::Event qw(:all);    # gives us newevent()

our @EXPORT = qw(keyadd KEYSET);                             # (:C cbexport)
our %EXPORT_TAGS = ( 'keyset' => [ qw(keyadd KEYSET) ] );    # (:C cbexport)

our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Keymap->newwidget(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newwidget {
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   # map our exportable functions

   if ($start) {

      # statics

      $self->cbmap();     # create a method map
      $self->KEYSET();    # init global default keyset
      $self->{'CURPOS'} = [ 0, 0 ];

      # This might seem like an unlikely place to invent this
      # into the main namespace, but the invocant needs to be
      # AUTOLITHIC, which Pdt::Form is not. It also needs to
      # be pretty global since we may want to dump it for
      # a lot of debugging, anyway, if we are messing with
      # terms, there will always be a keymap, so here we are.

   } else {

      # runtime completeness checks

   }

   $self->AUTOMAP(@_);

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.)

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'bindkeymap'}   = sub { shift; return $self->bindkeymap(@_); };
   $self->{'cbmap'}->{'curleft'}      = sub { shift; return $self->curleft(@_); };
   $self->{'cbmap'}->{'curpos'}       = sub { shift; return $self->curpos(@_); };
   $self->{'cbmap'}->{'curright'}     = sub { shift; return $self->curright(@_); };
   $self->{'cbmap'}->{'keyadd'}       = sub { shift; return $self->keyadd(@_); };
   $self->{'cbmap'}->{'KEYSET'}       = sub { shift; return $self->KEYSET(@_); };
   $self->{'cbmap'}->{'key2keyevent'} = sub { shift; return $self->key2keyevent(@_); };
   $self->{'cbmap'}->{'unbindkeymap'} = sub { shift; return $self->unbindkeymap(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

# bindkeymap trees all keystroke dispatch. It is monolithic, and pages
# based on page focus. So it is important than any focus event, also
# call bindkeymap to reset the key bindings.

sub bindkeymap {    #
   my $self = shift;

   my $F = $self->{'FOCUS'}->thisform();
   my $W = $self->{'FOCUS'}->thiswidget();
   my $T = $F->{'TEMPLATE'};

   # zero the default keyset

   $self->KEYSET();

   # cascade in order or precedence callbacks into our keyset.

   # HERE, changing focus is not resetting our thiswidget  vvv

   bonk "KEYMAP", "\t\tKEYSET donors: ", $F, " ", $W, " ", $T;

   bonk "KEYMAP", "\t\tKEYSET donor callback code: ", $F->{'cbmap'}->{'KEYSET'}, " ", $W->{'cbmap'}->{'KEYSET'}, " ", $T->{'cbmap'}->{'KEYSET'};

   bonk "KEYMAP", "\t\tKEYSET widget callback block: ", $W, " ", $W->{'cbmap'};

   $self->keyadd( $F->KEYSET() ) if ( ref( $F->{'cbmap'}->{'KEYSET'} ) eq 'CODE' );
   $self->keyadd( $W->KEYSET() ) if ( ref( $W->{'cbmap'}->{'KEYSET'} ) eq 'CODE' );
   $self->keyadd( $T->KEYSET() ) if ( ref( $T->{'cbmap'}->{'KEYSET'} ) eq 'CODE' );

   bonk "KEYMAP", "\t\tKEYSET keys in widget: ",   join ",", ( keys( %{ $W->{'KEYSET'} } ) );
   bonk "KEYMAP", "\t\tKEYSET keys in form: ",     join ",", ( keys( %{ $F->{'KEYSET'} } ) );
   bonk "KEYMAP", "\t\tKEYSET keys in template: ", join ",", ( keys( %{ $T->{'KEYSET'} } ) );

   bonk "KEYMAP", "\t\tKEYMAP total keys bound:", scalar( keys( %{ $self->{'KEYSET'} } ) );

   return ();
}

sub unbindkeymap {    # no special bound
   my $self = shift;
   bonk "KEYMAP", "\tKEYMAP $self";
   $self->{'KEYSET'} = undef;
   $self->KEYSET();
}

sub key2keyevent {    # convert a keypress to a key event
   my $self     = shift;
   my $WINDOW   = shift;
   my $CFFORM   = shift;
   my $CFWIDGET = shift;
   my $pkey     = shift;

   my $formname = $CFFORM->{'NAME'};
   my $fname    = $CFWIDGET->{'fname'};

   bonk "KEYMAP", "\tKEYMAP formname fieldname key: ", $formname, " ", $fname, " ", $pkey;

   # if there is a keymapped callback, hand it back as an event

   # bonk "KEYMAP", "KEYMAP:", Dumper( $self->{'KEYTABLE'} );

   my $E = newevent();

   if ( ref( $self->{'KEYSET'}->{$pkey} ) eq 'CODE' ) {

      $E->window($WINDOW);
      $E->form($CFFORM);
      $E->widget($CFWIDGET);
      $E->pkey($pkey);
      $E->action( $self->{'KEYSET'}->{$pkey} );

      # note here, that keymap actions may return full event objects,
      # including parameters. So key events themselves do not need to
      # concern themselves with params.

      bonk "KEYMAP", "\tMAPPED KEY: ", $pkey, ":", $self->{'KEYSET'}->{$pkey};

      return $E;
   }

   # if there isn't a keymapped callback but there is an "unmappedkey" callback
   # in the widget itself, call that.

   if ( ref( $CFWIDGET->{'cbmap'}->{'unmappedkey'} ) eq 'CODE' ) {
      $E = newevent( undef, $CFFORM, $CFWIDGET, $pkey, $CFWIDGET->{'cbmap'}->{'unmappedkey'}, undef );
      bonk "KEYMAP", "\tKEYMAP UNMAPPED KEY: ", $pkey, ":", $CFWIDGET->{'cbmap'}->{'unmappedkey'};
      return $E;
   }

   return ();
}

#### CURSOR STORAGE

sub curpos {    # (:M setget)
   my $self = shift;

   return ( @{ $self->{'CURPOS'} } ) unless ( scalar(@_) );    #

   $self->{'CURPOS'}->[ 0 ] = $_[ 0 ];                         # row
   $self->{'CURPOS'}->[ 1 ] = $_[ 1 ];                         # col

   return ( @{ $self->{'CURPOS'} } );
}

sub curright {                                                 #
   my $self = shift;
   $self->{'CURPOS'}->[ 1 ]++;
   return ( @{ $self->{'CURPOS'} } );
}

sub curleft {                                                  #
   my $self = shift;
   $self->{'CURPOS'}->[ 1 ]--;
   return ( @{ $self->{'CURPOS'} } );
}

#### BASE KEYSET

#: KEYSET and keyadd:

#: these two functions provide the basis for key dispatch aggregation.
#: every widget should define a KEYSET (:M keyset)

sub keyadd {    # overlay user defined keys into the form
   my $self    = shift;
   my $keyhash = shift;

   $self->{'KEYSET'} = {} unless ( defined $self->{'KEYSET'} );

   if ( ref($keyhash) eq 'HASH' ) {
      foreach my $k ( keys(%$keyhash) ) {
         if ( ref( $keyhash->{$k} ) eq 'CODE' ) {
            $self->{'KEYSET'}->{$k} = $keyhash->{$k};
         } else {
            bonk "KEYMAP", "\t\tKEYMAP found non code callback for $k";
         }
      }
   }

   return $self->{'KEYSET'};
}

sub KEYSET {    #
   my $self = shift;
   $self->{'KEYSET'} = {} unless ( defined $self->{'KEYSET'} );
   $self->keyadd(@_) if scalar(@_);
   return $self->{'KEYSET'};
}

1;
