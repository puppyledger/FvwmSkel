package Pdt::Term::Autocomp;    # (P: o)

#:
#: Autocompletion features for terminals
#:
#: This class is implemented in the context of a command
#: line history, though it may be used with any dataset.
#:

use Pdt::O qw(:all);
use Pdt::Term;
our @ISA = qw(Pdt::Term);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Term::Autocomp->newterm(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newterm {
   my $class = shift;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   # map our exportable functions

   if ($start) {

      # statics

      $self->cbmap();    # create a method map

      $self->{'HIST'}    = [];
      $self->{'MAXHIST'} = 10;
      $self->{'HISTPTR'} = 0;

      $self->AUTOPOPULATE(@_);

   } else {

      # runtime completeness checks

   }

   # stack cleanup

   return $self;
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.)

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'fqc'}          = sub { shift; return $self->fqc(@_); };
   $self->{'cbmap'}->{'pushhist'}     = sub { shift; return $self->pushhist(@_); };
   $self->{'cbmap'}->{'shifthist'}    = sub { shift; return $self->shifthist(@_); };
   $self->{'cbmap'}->{'shifthistnew'} = sub { shift; return $self->shifthistnew(@_); };
   $self->{'cbmap'}->{'unshifthist'}  = sub { shift; return $self->unshifthist(@_); };
   $self->{'cbmap'}->{'update'}       = sub { shift; return $self->update(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

sub update {    # update the current list of commands
   my $self = shift;
   $self->{'AUTOCOMPLIB'} = shift @_ if ( ref( $_[ 0 ] ) eq 'HASH' );
}

# fully qualify command returns a command, or undef, and a bell flag
# if the there are multiple matches. We recieve a character list, and
# we return a character list.

sub fqc {       # fully qualify the command (autocomplete)
   my $self = shift;    #
   my @ib   = @_;       # input buffer character list

   # warn @ib ;

   return undef unless scalar(@ib);    # shortcut a tab on a blank line.

   my $command = join "", @ib;
   my @cleanblock = $self->string2clean($command);
   $command = shift(@cleanblock);

   my @k = keys( %{ $self->{'AUTOCOMPLIB'} } );

   # warn "autocompleting for commands: ", scalar(@k) ;

   my @matches = grep { /^$command/ } @k;

   # warn "matches:", scalar(@matches) ;

   my @c = ();    # the returning character list

   # no match, return just the bell.

   return (1) unless scalar(@matches);

   # exactly one match, return it, no bell.

   if ( scalar(@matches) == 1 ) {
      @c = split( "", $matches[ 0 ] );
      return ( @c, undef );
   }

   # sort the matches by string length, and get
   # the max length of the longest line.

   @matches = sort { length $a <=> length $b } @matches;
   my $maxlength = length( $matches[ scalar(@matches) - 1 ] );

   # then walk the list of matches per character left to right until
   # there is a divergence. As soom as they diverge we check to see
   # if the command in hand is the exact length of a of the uniqueness
   # and prune the extra character if not. This allows foo and foobar
   # AND doodum and doodam (without dood).

   my $commonlead;    # the maximum length of characters
   my $diverge    = 0;
   my $matchcount = scalar(@matches);
   my $compare;
   my $cval;
   my $width;
   my $bestmatch;

   for ( my $n = 1 ; $n <= $maxlength ; $n++ ) {

      # warn "rotation: ", $n  ;
      last if $diverge;
      for ( my $N = 0 ; $N < $matchcount ; $N++ ) {
         if ( $N == 0 ) {
            $compare = substr( $matches[ $N ], 0, $n );
            next;
         }
         $cval = substr( $matches[ $N ], 0, $n );

         # warn "\tcval: $cval\n" ;
         unless ( $compare eq $cval ) {
            $width     = $N - 1;
            $bestmatch = $cval;
            chop $bestmatch if length($cval) > $N;
            $diverge = 1;
            last;
         }
      }
   }

   # return them and a bell.

   @c = split( "", $bestmatch );

   return ( @c, 1 );
}

### HISTORY

sub pushhist {    # add the current command line to the history
   my $self = shift;
   my @ib   = @_;
   my $IB   = [ @ib ];

   my $gone = undef;

   unshift @{ $self->{'HIST'} }, $IB;
   $gone = pop( @{ $self->{'HIST'} } ) if scalar( @{ $self->{'HIST'} } ) > $self->{'MAXHIST'};

   @ib   = ();
   $gone = undef;

   return undef;
}

sub shifthist {    # rotate the history
   my $self = shift;
   return @_ unless scalar( @{ $self->{'HIST'} } );
   $self->{'HISTPTR'}++ if scalar( @{ $self->{'HIST'} } ) > $self->{'HISTPTR'};
   return @{ ${ $self->{'HIST'} }[ $self->{'HISTPTR'} ] };
}

sub shifthistnew {    # rotate the history if we are not already in the history
   my $self = shift;
   $self->{'HISTPTR'} = 0;
   return $self->shifthist(@_);
}

sub unshifthist {     # rotate the history back.
   my $self = shift;
   $self->{'HISTPTR'} = $self->{'HISTPTR'} - 2 if $self->{'HISTPTR'} > 0;
   return $self->shifthist(@_);
}

1;
