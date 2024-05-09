package Pdt::Form::Password;    # (P: o)

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Password Widget for Pdt Forms

use Pdt::O qw(:all);
use Pdt::Form::Widget;
use Pdt::Bonk qw(:all);
use Data::Dumper qw(Dumper);

use Pdt::Form::API qw(:all);
use Pdt::Form::Event qw(:all);     # event objects
use Pdt::Form::Keyset qw(:all);    # keyadd (probably to move to Keymap, and then to Focus)

our @ISA = qw(Pdt::Form::Widget);

use strict;

### CONSTRUCTORS

sub newwidget {
   my $class = shift;

   my ( $self, $start ) = PLUROLITH($class);    # object registration

   # interpolate the engines component classes

   # map our exportable functions

   if ($start) {

      # statics

      $self->initapi();
      $self->cbmap();    # create a method map
      $self->KEYSET();

   } else {

      # runtime completeness checks

   }

   $self->AUTOMAP(@_);

   # stack cleanup

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.)

#: HERE < ---------
#: for some reason we can't cbmap Pdt::Form::Widget into ourselves... Hmm.

sub cbmap { # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The  cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'dropfocus'}      = sub { shift; return $self->dropfocus(@_); };
   $self->{'cbmap'}->{'focusnext'}      = sub { shift; return $self->focusnext(@_); };
   $self->{'cbmap'}->{'focusprev'}      = sub { shift; return $self->focusprev(@_); };
   $self->{'cbmap'}->{'foo'}            = sub { shift; return $self->foo(@_); };
   $self->{'cbmap'}->{'insertchar'}     = sub { shift; return $self->insertchar(@_); };
   $self->{'cbmap'}->{'key_backspace'}  = sub { shift; return $self->key_backspace(@_); };
   $self->{'cbmap'}->{'key_delete'}     = sub { shift; return $self->key_delete(@_); };
   $self->{'cbmap'}->{'key_leftarrow'}  = sub { shift; return $self->key_leftarrow(@_); };
   $self->{'cbmap'}->{'key_rightarrow'} = sub { shift; return $self->key_rightarrow(@_); };
   $self->{'cbmap'}->{'KEYSET'}         = sub { shift; return $self->KEYSET(@_); };
   $self->{'cbmap'}->{'registerfocus'}  = sub { shift; return $self->registerfocus(@_); };
   $self->{'cbmap'}->{'registerkeymap'} = sub { shift; return $self->registerkeymap(@_); };
   $self->{'cbmap'}->{'replacechar'}    = sub { shift; return $self->replacechar(@_); };
   $self->{'cbmap'}->{'takefocus'}      = sub { shift; return $self->takefocus(@_); };
   $self->{'cbmap'}->{'unmappedkey'}    = sub { shift; return $self->unmappedkey(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

# :M <yourmethod> (build methods from templates)

# we are doing this via inheritance, this is just here to show it.

#### REGISTER

sub registerfocus { # M: stacksuper
   my $self = shift;
   return ( $self->SUPER::registerfocus(@_) );
}

sub registerkeymap { # M: stacksuper
   my $self = shift;
   return ( $self->SUPER::registerkeymap(@_) );
}

#### FOCUS

sub focusnext { # M: stacksuper
   my $self = shift;
   bonk "WIDGET", "WIDGET ENTRY FOCUS NEXT";
   $self->SUPER::focusnext(@_);
   return ();
}

sub focusprev { # M: stacksuper
   my $self = shift;
   bonk "WIDGET", "WIDGET ENTRY FOCUS PREV";
   $self->SUPER::focusprev(@_);
   return ();
}

sub dropfocus { # Pdt::Form::dropfocus
   my $self = shift;
   return ( $self->SUPER::dropfocus(@_) );
}

sub takefocus { # Pdt::Form::takefocus
   my $self = shift;
   return ( $self->SUPER::takefocus(@_) );
}

#### KEY PROCESSING

sub unmappedkey { # 
   my $self  = shift;
   my $event = shift;

   # We have an unmapped key, we know it is destined for us, so we
   # assume that it is user data, and try to print it out like gentlemen.

   # here entries adopt the forms insert/replace settings
   # we need to know about this for every keystroke, so
   # we just do it.

   bonk 'WIDGET', "\tENTRY unmapped key";

   $self->{'freplacemode'} = $self->{'FORM'}->{'REPLACEMODE'};

   if ( $self->{'freplacemode'} ) {
      $self->replacechar( $event->pkey() );
   } else {
      $self->insertchar( $event->pkey() );
   }

   return ();
}

# print a character in insert mode

sub insertchar {
   my $self = shift;
   my $c    = shift;    # this is the ord

   $c = chr($c);

   bonk 'WIDGET', "\tENTRY inserting character: ", $c;

   $self->{'fcuroffset'} = 0 unless ( defined $self->{'fcuroffset'} );

   # attempting to print or insert off the end

   if ( $self->{'fcuroffset'} >= $self->{'flength'}
      || length( ${ $self->{'fvalue'} } ) >= $self->{'flength'} )
   {

      $self->bell();    #

      # the field is blank, print the char

   } elsif ( length( ${ $self->{'fvalue'} } ) == 0 ) {

      $self->{'SCREEN'}->puts($c);
      $self->{'KEYMAP'}->curright();
      ${ $self->{'fvalue'} } = $c;
      $self->{'fcuroffset'}++;

      # the field has data, we are prepending it

   } elsif ( $self->{'fcuroffset'} == 0 ) {

      my @fvbychar = split "", ${ $self->{'fvalue'} };    # break it out into an array
      unshift( @fvbychar, $c );                           # prepend the chracter
      ${ $self->{'fvalue'} } = join "", @fvbychar;        # recreate the value
      $self->{'SCREEN'}->puts( ${ $self->{'fvalue'} } );  # we can simply print over the whole value
      $self->{'fcuroffset'}++;                            # move the cursor ptr to the right by 1 from initial
      $self->placecur2offset();                           # replace the cursor

      # the field has data, we are appending it

   } elsif ( $self->{'fcuroffset'} == length( ${ $self->{'fvalue'} } ) ) {

      my @fvbychar = split "", ${ $self->{'fvalue'} };    # break it out into an array
      push( @fvbychar, $c );                              # append the chracter
      ${ $self->{'fvalue'} } = join "", @fvbychar;        # recreate the value
      $self->{'SCREEN'}->puts($c);                        # we can simply print the character
      $self->{'KEYMAP'}->curright();
      $self->{'fcuroffset'}++;                            # move the cursor ptr to the right by 1 from initial

      # the field has data we are in it somewhere

   } else {

      my @fvrear = split "", ${ $self->{'fvalue'} };      # break it out into an array
      my @fvfront = splice( @fvrear, 0, $self->{'fcuroffset'} );    # split it into before and after cursor
      push @fvfront, $c;                                            # add the character to the end of the forward block
      ${ $self->{'fvalue'} } = join "", @fvfront, @fvrear;          # reassemble the value
      $self->{'SCREEN'}->puts($c);
      $self->{'SCREEN'}->puts( ( join "", @fvrear ) );
      $self->{'fcuroffset'}++;                                      # move the cursor ptr to the right by 1 from initial
      $self->placecur2offset();                                     # replace the cursor

   }

   return ();
}

# print a character in replace mode

sub replacechar { # <------------------- HERE
   my $self = shift;
   my $c    = shift;                                                # this is the ord
   $c = chr($c);
   return ();
}

#### KEYMAPPED METHODS

sub key_backspace { # 
   my $self = shift;
   bonk 'WIDGET', "\tENTRY key_backspace called";

   $self->{'freplacemode'} = $self->{'FORM'}->{'REPLACEMODE'};
   $self->{'fcuroffset'} = 0 unless ( defined $self->{'fcuroffset'} );

   # we cannot backspace past position zero

   if ( $self->{'fcuroffset'} == 0 ) {
      $self->bell();

      # insert mode, we backspace and drag the characters with us

   } elsif ( $self->{'freplacemode'} == 0 ) {

      my @fv = split "", ${ $self->{'fvalue'} };    #

      # web have to get a substring, plus add a space

      my @endv  = @fv;                                        # characters to preserve
      my $toend = ( scalar(@fv) - $self->{'fcuroffset'} );    # number characters to preserve
      @endv = splice( @endv, $self->{'fcuroffset'}, $toend ); # preserve them
      push( @endv, " " );                                     # add a space to override the trailing rear
      my $endstring = join '', @endv;

      $self->{'fcuroffset'}--;                                # set the index to the left
      splice( @fv, $self->{'fcuroffset'}, 1 );                # do the backspace in the value
      ${ $self->{'fvalue'} } = join "", @fv;

      bonk "SCREEN", "SCREEN HERE";

      $self->{'SCREEN'}->curinvis();
      $self->{'SCREEN'}->at( $self->{'KEYMAP'}->curleft() );
      $self->{'SCREEN'}->puts($endstring);
      $self->{'SCREEN'}->at( $self->{'KEYMAP'}->curpos() );
      $self->{'SCREEN'}->curvis();

      # go to the end character of the value and space over it
      # then backspace a clear position, and rewrite over
      # everything to the right.

      # replace mode

   } elsif ( $self->{'freplacemode'} ) {

      # like a spacebar printing except to the left.

      $self->{'SCREEN'}->curinvis();
      $self->{'SCREEN'}->at( $self->{'KEYMAP'}->curleft() );
      $self->{'SCREEN'}->puts(' ');
      $self->{'SCREEN'}->at( $self->{'KEYMAP'}->curpos() );
      $self->{'fcuroffset'}--;
      $self->{'SCREEN'}->vis();

      my @fv = split "", ${ $self->{'fvalue'} };
      splice( @fv, $self->{'fcuroffset'}, 1, " " );
      ${ $self->{'fvalue'} } = join( "", @fv );

   }

   return ();
}

sub key_delete { # delete, truncating to the right
   my $self = shift;

   bonk 'WIDGET', "\tENTRY key_delete called";

   # HERE <------------- but different
}

sub key_leftarrow { # 
   my $self = shift;

   bonk 'WIDGET', "\tENTRY key_leftarrow called";

   $self->{'fcuroffset'} = 0 unless ( defined $self->{'fcuroffset'} );

   if ( $self->{'fcuroffset'} == 0 ) {
      $self->bell();
   } else {
      $self->{'fcuroffset'}--;
      $self->{'SCREEN'}->at( $self->{'KEYMAP'}->curleft() );
   }

   return ( $self->{'KEYMAP'}->curpos() );
}

sub key_rightarrow { # 
   my $self = shift;

   bonk 'WIDGET', "\tENTRY key_rightarrow called";

   if ( $self->{'fcuroffset'} == $self->{'flength'} ) {
      $self->bell();
   } else {
      $self->{'fcuroffset'}++;
      $self->{'SCREEN'}->at( $self->{'KEYMAP'}->curright() );
   }

   return ( $self->{'KEYMAP'}->curpos() );
}

#### KEYSET

sub foo { # (M: stacksuper)
   my $self = shift;
   return ( $self->SUPER::foo(@_) );
}

sub KEYSET { # (:M keyset)
   my $self = shift;

   unless ( defined $self->{'KEYSET'} ) {

      $self->SUPER::KEYSET(@_);

      $self->keyadd(
         {
            '127'       => $self->{'cbmap'}->{'key_backspace'},     # DEL
            '27100'     => $self->{'cbmap'}->{'debug_fval'},        # alt-d
            '2791650'   => $self->{'cbmap'}->{'focusprev'},         # see Pdt::Form
            '2791660'   => $self->{'cbmap'}->{'focusnext'},         # see Pdt::Form
            '2791670'   => $self->{'cbmap'}->{'key_rightarrow'},    #
            '2791680'   => $self->{'cbmap'}->{'key_leftarrow'},     #
            '279151126' => $self->{'cbmap'}->{'key_delete'}         #
         }
      );

   }

   bonk "KEYMAP", "\t\tKEYSET ", $self, " announcing keys: ", scalar( keys( %{ $self->{'KEYSET'} } ) );

   return $self->{'KEYSET'};
}

1;
