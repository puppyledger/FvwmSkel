package Pdt::Method_FormMap;    # (P: o)

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

#: (M: formmap) may guess field parameters for certain fields.
#: This object exists to ceate that guessing code.

use Pdt::O qw(:all);
our @ISA = qw(Pdt::O);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

# Our real constructors are name-common only within the API to prevent inheritance collision

sub new {
   my $class = shift;

   # my %OPT = @_ ;

   my ( $self, $start ) = AUTOLITH($class);    # self registering object
                                               # my ($self, $start) = PLUROLITH($class) ; # record style object

   # $self->{'FOO'} = delete $OPT{'FOO'} if exists $OPT{'FOO'} ;

   if ($start) {                               # A, true only on first run. P, always true

      # uncomment to enable callbacks
      $self->cbmap();                          # create with C: cbmap

      # HERE, at some future date, we may extend formmap to have a
      # formalized basis for setting

      $self->{'SPECIAL'} = {
         'ftext'     => qw[entry password checkbox button],
         'fselected' => qw[checkbox readiobutton]
      };

   } else {

      # runtime completeness checks

   }

   # anything not yet deleted autowrites to properties
   $self->AUTOPOPULATE(@_);

   # anything not yet deleted autoexecutes to methods, OR autowrites properties
   # $self->AUTOMAP(@_) ;

   return $self;
}

### CALLBACKS

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'ftext_button'}   = sub { shift; return $self->ftext_button(@_); };
   $self->{'cbmap'}->{'ftext_checkbox'} = sub { shift; return $self->ftext_checkbox(@_); };
   $self->{'cbmap'}->{'ftext_entry'}    = sub { shift; return $self->ftext_entry(@_); };
   $self->{'cbmap'}->{'ftext_password'} = sub { shift; return $self->ftext_password(@_); };
   $self->{'cbmap'}->{'makeftext'}      = sub { shift; return $self->makeftext(@_); };

   return ( $self->{'cbmap'} );
}

#### FTEXT

sub makeftext {
   my $self = shift;
   my $f    = shift;    # ffullname

   #my ($fname, $ftype, $fcoloffset, $frowoffset, $flength) = split( /\_/, $f ) ;

   my @foo = split( /\_/, $f );
   my $ftcb = "ftext_" . $foo[ 1 ];

   if ( ref( $self->{'cbmap'}->{$ftcb} ) eq 'CODE' ) {
      return ( &{ $self->{'cbmap'}->{$ftcb} }( $self, @foo ) );
   }

   return ();
}

sub ftext_button { # (:M setget)
   my $self = shift;
   my ( $fname, $ftype, $fcoloffset, $frowoffset, $flength ) = @_;

   # if the name of the field is longer than the field, truncate it.

   my $ftext = substr( $fname, 0, $flength );    # remove additional character again if even lengths.

   if ( length($ftext) == $flength ) {           # field length was shorter than or equal to supplied name

      return $ftext;

   } else {

      # create l/r blank space pad.

      my $pad = ( $flength - length($ftext) );
      $pad = int( ( $pad / 2 ) );

      warn "flength: $flength  ftext: ", length($ftext), "pad: $pad";

      # sleep 4;

      my $padtext;
      for ( my $n = 0 ; $n < $pad ; $n++ ) {
         $padtext .= " ";
      }

      # add it to the text.

      $ftext = $padtext . $fname . $padtext . " ";    # add a character for odd lengths.
      $ftext = substr( $ftext, 0, $flength );         # remove additional character again if even lengths.

      return $ftext;
   }

   # should never get here.

   return ();
}

sub ftext_checkbox { # (:M setget)
   my $self = shift;
   return ' ';
}

sub ftext_entry { # (:M setget)
   my $self = shift;

   my ( $fname, $ftype, $fcoloffset, $frowoffset, $flength ) = @_;
   my $ftext;
   for ( my $n = 0 ; $n < $flength ; $n++ ) {
      $ftext .= ' ';
   }

   return $ftext;
}

sub ftext_password { # (:M setget)
   return ( ftext_entry(@_) );
}

### fbool

1;
