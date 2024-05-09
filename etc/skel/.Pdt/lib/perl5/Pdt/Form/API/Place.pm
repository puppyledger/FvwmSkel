package Pdt::Form::API::Place;    # EXPORTONLY (:P x)

# #
my $VERSION = '2018-04-13.07-05-04.EDT';

#: cursor placement and movement functions

use Pdt::Screen;
use Pdt::Bonk qw(:all);

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(placecur2offset placeemptyform placefocus placeform placekey placewipeform place2del place2insert place2update);    # (:C cbexport)
our %EXPORT_TAGS =
  ( 'all' => [ qw(placecur2offset placeemptyform placefocus placeform placekey placewipeform place2del place2insert place2update) ] );    # (:C cbexport)

use strict;

#### DRAWING (aggregates graphical calculations into common tasks)

#### PLACEMENT (does graphical calculations)

# write a form, including content data,

sub placewipeform { # wipe a screen area defined by a form
   my $self = shift;

   my $F = $self->thisform();

   my $col = $F->COL();
   my $row = $F->ROW();

   my ( $tlcol, $tlrow ) = ( @{ $F->{'ALIGN'} } );

   my $blankline;

   for ( my $n = 0 ; $n < $col ; $n++ ) {
      $blankline .= " ";
   }

   my $ln = 0;

   for ( my $r = 0 ; $r < $row ; $r++ ) {
      my $linepos = $tlrow + $r;
      $F->{'SCREEN'}->at( $linepos, $tlcol );
      $F->{'SCREEN'}->puts($blankline);
      $F->{'KEYMAP'}->curpos( $linepos, ( $tlcol + length($blankline) ) );
   }

   return ();
}

sub placeform { # draw the template, with new params if provided.
   my $self = shift;

   my %param;

   if ( scalar(@_) ) {
      unless ( scalar(@_) % 2 ) {
         %param = @_;
      }
   }

   bonk "PLACE", "PLACE starting with arguments: ", scalar(@_);

   # whatever the currently focused form, get the template

   # template does not exist. It should.
   # debug.

   my $f = $self->thisform();
   my $F = $f->PARENTFRAME();
   my $T = $f->TEMPLATE();

   # the screen placement configured in the form

   my ( $tlcol, $tlrow ) = ( @{ $f->{'ALIGN'} } );

   bonk "PLACE", "PLACE placeform: form parentframe template: ", $f, " ", $F, " ", $T;
   bonk "PLACE", "PLACE form alignment: ", $tlcol, " ", $tlrow;

   return () unless ( defined $T );

   my @thisline;

   if ( scalar( keys(%param) ) ) {
      $T->clearfields();
      $T->append(%param);
      @thisline = split( "\n", $T->output() );
   }

   @thisline = split( "\n", $T->output() );

   bonk "PLACE", "\ttemplate output lines: ", " ", scalar(@thisline);

   my $ln = 0;

   foreach my $oneline (@thisline) {
      my $linepos = $tlrow + $ln;
      $F->{'SCREEN'}->at( $linepos, $tlcol );
      $F->{'SCREEN'}->puts($oneline);
      $F->{'KEYMAP'}->curpos( $linepos, ( $tlcol + length($oneline) ) );
      $ln++;
   }

   bonk "PLACE", "\ttemplate lines placed: ", " ", $ln;

   return ();
}

sub placeemptyform { # 
   my $self = shift;

   my $F = $self->thisform();
   my $T = $F->TEMPLATE();

   $T->clearfields();
   $self->placeform();

   return ();
}

# We place the cursor in the widget on the basis that the widget,
# should already know what it's cursor offset should be.

sub placefocus { # 
   my $self = shift;

   my $F = $self->thisform();
   my $W = $self->thiswidget();

   bonk 'PLACE', "PLACE form and widget: ", $F, " ", $W;

   # add form alignment offsets, to the focused widgets offsets

   my ( $facol, $farow ) = $F->align();

   bonk 'PLACE', "PLACE form top left: ", $facol, " ", $farow;
   bonk 'PLACE', "PLACE widget top left: ", $W->{'fcoloffset'}, " ", $W->{'frowoffset'};
   bonk 'PLACE', "PLACE cursor offset: ", $W->{'fcuroffset'};

   my $wocol = ( $W->{'fcoloffset'} + $facol );
   my $worow = ( $W->{'frowoffset'} + $farow );

   # if the cursor position inside the widget has been manually adjusted,
   # add that offset.

   if ( defined $W->{'fcuroffset'} ) {
      $wocol = ( $wocol + $W->{'fcuroffset'} );
   }

   bonk 'PLACE', "PLACE focus decision: ", $wocol, " ", $worow;

   $F->{'SCREEN'}->at( $F->{'KEYMAP'}->curpos( $worow, $wocol ) );
}

sub placekey { # 
   my $self = shift;
   my $c =

     my $F = shift;    # FORM
   my $W = shift;      # WIDGET
   my $T = shift;      # TEMPLATE
   my $A = shift;      # ALIGN
   my $S = shift;      # SCREEN
   my $O = shift;      # FOCUS

   # detect the currently focused widget,
   # and run the widgets specific placekey
   # function.
}

sub place2del { # delete the value, blank the field, zero the cursor
   my $self = shift;

   my $oldlength = length( ${ $self->{'fvalue'} } );

   $self->{'fcuroffset'} = 0;
   $self->takefocus();

   my $blank;

   for ( my $n = 0 ; $n < $oldlength ; $n++ ) {
      $blank .= " ";
   }

   $self->{'SCREEN'}->puts($blank);

   ${ $self->{'fvalue'} } = "";
   $self->{'fcuroffset'} = 0;

   $self->takefocus();
}

sub place2insert { # inserts wherever the cursor currently is and writes fval
   my $self = shift;
   my $val  = shift;

   # here, take a string value, insert it at the current position
   # and move the cursor to the right the number of inserted character
   # positions, just as if a mouse paste has taken place.

   return () unless ( length($val) );

   my $startlength  = length( ${ $self->{'fval'} } );
   my $insertlength = length($val);
   my $endlength    = $startlength + $insertlength;
   my $endoffset    = $self->{'fcuroffset'} + insertlength();

   unless ( length( ${ $self->{'fval'} } ) ) {
      $self->place2del();    # get rid of anything on the screen
      ${ $self->{'fval'} } = $val;
      $self->{'fcuroffset'} = length($val);
      $self->{'fcuroffset'}++;
      $self->{'SCREEN'}->puts( ${ $self->{'fval'} } );
   } else {
      my @valchar = split( '', ${ $self->{'fval'} } );
      my @inschar = split( '', ${ $self->{'fval'} } );
      my @pushchar = splice( @valchar, $self->{'fcuroffset'} );
      push @valchar, ( @inschar, @pushchar );
      ${ $self->{'fval'} } = join "", @valchar;
      $self->{'fcuroffset'} = $endoffset;
   }

   my @EVENT = $self->takefocus();
   bonk "PLACE", "\tPLACE place2insert returning event count: ", @EVENT;
   return @EVENT;
}

# when we update whole forms, the underlying values are updated
# in batch, and then the field updates must be called indevidually

sub place2update { # 
   my $self = shift;
   my $fval = ${ $self->{'fvalue'} };
   $self->place2del();
   return ( $self->paste2insert($fval) );
}

#### WIDGET

sub placecur2offset { # Widget calls this to set the cursor to the current offset position
   my $W = shift;
   my $F = $W->{'FORM'};

   bonk 'PLACE', "PLACE form and widget: ", $F, " ", $W;

   # add form alignment offsets, to the focused widgets offsets

   my ( $facol, $farow ) = $F->align();

   bonk 'PLACE', "PLACE form top left: ", $facol, " ", $farow;
   bonk 'PLACE', "PLACE widget top left: ", $W->{'fcoloffset'}, " ", $W->{'frowoffset'};
   bonk 'PLACE', "PLACE cursor offset: ", $W->{'fcuroffset'};

   my $wocol = ( $W->{'fcoloffset'} + $facol );
   my $worow = ( $W->{'frowoffset'} + $farow );

   # if the cursor position inside the widget has been manually adjusted,
   # add that offset.

   if ( defined $W->{'fcuroffset'} ) {
      $wocol = ( $wocol + $W->{'fcuroffset'} );
   }

   bonk 'PLACE', "PLACE focus decision: ", $wocol, " ", $worow;

   $W->{'SCREEN'}->at( $W->{'KEYMAP'}->curpos( $worow, $wocol ) );

   return ();
}

1;
