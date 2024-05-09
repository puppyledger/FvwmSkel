package Pdt::Term::Cli;    # (P: o)

#: Cli IO controller

use Fcntl qw(F_GETFL F_SETFL O_NONBLOCK);    # OS specific C symbols or file handling.
use POSIX qw(:errno_h);                      # prens required to constrain imported namespace
use Term::ReadKey;                           # Provides ReadMode Setting

use Pdt::O qw(:all);
use Pdt::Bonk qw(:all);
use Pdt::Term;
use Pdt::Term::Cap qw(:all);
use Pdt::Term::Autocomp;

our @ISA = qw(Pdt::Term);

# imports from Pdt::Term::Cap

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Term::Cli->newterm(@_); }

# Our real constructors are name-common only within the API to prevent inheritance collision

sub newterm {
   my $class  = shift;
   my %option = @_;

   my ( $self, $start ) = AUTOLITH($class);    # object registration

   # interpolate the engines component classes

   # map our exportable functions

   if ($start) {

      $self->cbmap();                # create a method map
      $self->settermcap('xterm');    # Pdt::Term::Cap

      # character buffers

      $self->{'_input'}     = [];
      $self->{'_divert'}    = [];
      $self->{'_output'}    = [];
      $self->{'_writelock'} = 0;     # multiline-report print lock

      # common strings

      $self->{'cnf'}        = $class::STRCNF;                                       #
      $self->{'prompt'}     = $class::PROMPT unless length( $self->{'prompt'} );    #
      $self->{'modeprompt'} = $class::PROMPT;                                       # Prompts may be externally extended
      $self->{'modeflag'}   = 0;

      # command history

      $self->{'_cmdhist'}   = [];                                                   # array contains previous commands
      $self->{'_ctrlbf'}    = [];                                                   # character buffer for control sequences
      $self->{'_histindex'} = 0 unless defined $self->{'_histindex'};               #

      $self->{'AUTOCOMP'} = Pdt::Term::Autocomp->new() unless defined $self->{'AUTOCOMP'};

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
   $self->{'cbmap'}->{'appendhistory'}   = sub { shift; return $self->appendhistory(@_); };
   $self->{'cbmap'}->{'clrscreen'}       = sub { shift; return $self->clrscreen(@_); };
   $self->{'cbmap'}->{'cnf'}             = sub { shift; return $self->cnf(@_); };
   $self->{'cbmap'}->{'configureserial'} = sub { shift; return $self->configureserial(@_); };
   $self->{'cbmap'}->{'detectserial'}    = sub { shift; return $self->detectserial(@_); };
   $self->{'cbmap'}->{'drainbuffer'}     = sub { shift; return $self->drainbuffer(@_); };
   $self->{'cbmap'}->{'escalateprompt'}  = sub { shift; return $self->escalateprompt(@_); };
   $self->{'cbmap'}->{'gethistline'}     = sub { shift; return $self->gethistline(@_); };
   $self->{'cbmap'}->{'histblankline'}   = sub { shift; return $self->histblankline(@_); };
   $self->{'cbmap'}->{'histbyoffset'}    = sub { shift; return $self->histbyoffset(@_); };
   $self->{'cbmap'}->{'nbchar'}          = sub { shift; return $self->nbchar(@_); };
   $self->{'cbmap'}->{'prompt'}          = sub { shift; return $self->prompt(@_); };
   $self->{'cbmap'}->{'prompttext'}      = sub { shift; return $self->prompttext(@_); };
   $self->{'cbmap'}->{'saveserial'}      = sub { shift; return $self->saveserial(@_); };
   $self->{'cbmap'}->{'sCLOSE'}          = sub { shift; return $self->sCLOSE(@_); };
   $self->{'cbmap'}->{'sndeol'}          = sub { shift; return $self->sndeol(@_); };
   $self->{'cbmap'}->{'srchar'}          = sub { shift; return $self->srchar(@_); };
   $self->{'cbmap'}->{'srl'}             = sub { shift; return $self->srl(@_); };
   $self->{'cbmap'}->{'sw'}              = sub { shift; return $self->sw(@_); };
   $self->{'cbmap'}->{'tabcomplete'}     = sub { shift; return $self->tabcomplete(@_); };
   $self->{'cbmap'}->{'uparrow'}         = sub { shift; return $self->uparrow(@_); };
   $self->{'cbmap'}->{'writelock'}       = sub { shift; return $self->writelock(@_); };

   return ( $self->{'cbmap'} );
}

### METHODS

sub detectserial {    # bind filehandles for IO
   my $self = shift;

   # Here we implement some filehandle settings to emulate the serial port.

   fcntl( STDIN, F_SETFL, O_NONBLOCK );
   ReadMode 5;        # From Term::ReadKey

   fcntl( STDOUT, F_SETFL, O_NONBLOCK );
   autoflush STDOUT;

   # then glob up the handles to make the rest of the code more portable.

   $self->{'TTYR'} = *STDIN;                       # Read handle
   $self->{'FDR'}  = fileno( $self->{'TTYR'} );    # Read file descriptor number

   $self->{'TTYW'} = *STDOUT;                      # Write handle
   $self->{'FDW'}  = fileno( $self->{'TTYW'} );    # Write file descriptor number

   return ( $self->{'TTYR'}, $self->{'TTYW'} );
}

sub configureserial {                              # configure our serial port
   my $self = shift;
   return 1;
}

sub saveserial {                                   # probably deprecated.
   return 1;
}

#
## Pdt::Term::Autocomp contains a page of currently available
## commands. Pdt::Term::Cmd shifts that page with prompt escalation.
## here all we have to do is hand the input buffer to Pdt::Term::Autocomp
## and it gives us back its best guess at replacement text
## which we swap into place.
#
sub tabcomplete {                                  # autocomplete text input.
   my $self = shift;

   my $ib  = shift;                                # input character buffer
   my $ibl = scalar(@$ib);                         # current input buffer length
   my $ob  = $self->{'_output'};                   # buffer from which we print

   # warn "\r\n", "IB:", @$ib, " ", $ibl, "\r\n" ;
   # warn "OB:", @$ob, "\r\n" ;

   my $AC = $self->{'AUTOCOMP'};    # command autocompletion library

   # pass the input buffer to the autocompletion object

   my @fqc_char = $AC->fqc(@$ib);    # fully qualified command, as an array of characters.
   my $bell     = pop @fqc_char;     # last character is a bell flag designating full vs. partial completion
   @$ib = @fqc_char;                 # replace text input buffer with the tab completion
   my $cmdlength = scalar(@fqc_char);    # record the length.

   # here we use the length of the command buffer
   # we recieved to prepend backspaces to the
   # autocompleted command we are sending to the terminal.

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, "\b\ \b";    # prepend a backspace for sending to the terminal
   }

   # then we send the backspaces, command and bell to the terminal.

   my $string = join "", @fqc_char;

   $self->writelock(1);
   $self->sw($string);                # string write
   $self->sw($TERMBL) if $bell;
   $self->writelock(0);

   # and return its length.

   return $cmdlength;
}

## history is a circular list. It can be circular positively or negatively.
#
sub gethistline {                     #
   my $self    = shift;
   my $uparrow = shift;               # one if up arrow, zero if down

   # warn( join "\r\n", ( "START HISTINDEX: $self->{'_histindex'}", "" ) );

   my $h = scalar( @{ $self->{'_cmdhist'} } );    # the history size
   my $o;                                         # offset

   return undef unless $h;                        # nothing to do if no history

   # here we increment or decrement the history index
   # We supress the increment at one loop to prevent excessive looping.

   if ($uparrow) {    # uparrow scrolls deeper into the history
      $self->{'_histindex'}++;
      $self->{'_histindex'}-- if $self->{'_histindex'} > $h;

      # warn (join "\r\n", ("SIZE: $h", "INDEX:  $self->{'_histindex'}", "INCREMENT", " ")) ;
   } else {           # downarrow scrolls shallower, or backwards.
      $self->{'_histindex'}--;
      $self->{'_histindex'}++ if $self->{'_histindex'} < ( $h * -1 );

      # warn (join "\r\n", ("SIZE: $h", "INDEX:  $self->{'_histindex'}", "DECREMENT", " ")) ;
   }

   # if we scroll back onto position zero, send a blank line

   return $self->histblankline() if $self->{'_histindex'} == 0;

   # offset is always a positive number

   if ( $self->{'_histindex'} < 0 ) {
      $o = $self->{'_histindex'} * -1;
   } else {
      $o = $self->{'_histindex'};
   }

   # the adjusted offset is a modulus of the history index
   # adjusted for position zero.

   my $oa = $o % $h;
   $oa = $h if $oa == 0;

   # and we read backwards if in negative numbers

   if ( $self->{'_histindex'} < 0 ) {
      $oa = ( $h + 1 ) - $oa;
   }

   # warn (join "\r\n", ("SIZE: $h","INDEX:  $self->{'_histindex'}", "OFFSET: $o", "OFFSET ADJUSTED: $oa", "")) ;
   # warn (join "\r\n", ("END HISTINDEX: $self->{'_histindex'}", "")) ;

   # now we can shift the cli string with a pointer

   return $self->histbyoffset($oa);
}

sub histblankline {
   my $self = shift;

   # first we get the current input buffer

   my $ib  = $self->{'_input'};    # input buffer accumulates as we type
   my $ibl = scalar(@$ib);         # current input buffer length

   my @fqc_char;

   # then we accumulate backspaces

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, "\b";     # prepend a backspace for sending to the terminal
   }

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, " ";      # prepend a backspace for sending to the terminal
   }

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, "\b";     # prepend a backspace for sending to the terminal
   }

   @$ib = ();

   # then we write them to the CLI

   my $string = join "", @fqc_char;

   $self->writelock(1);
   $self->sw($string);             # string write
   $self->writelock(0);

   return undef;
}

sub histbyoffset {
   my $self = shift;
   my $oa   = shift;               # adjusted offset

   # first we get the current input     buffer

   my $ib  = $self->{'_input'};    # input buffer accumulates as we type
   my $ibl = scalar(@$ib);         # current input buffer length

   # decrement the circular index which is always higher by 1
   # then we get the command located at the pointer

   $oa--;
   my @fqc_char = split( '', $self->{'_cmdhist'}->[ $oa ] );    # get the target history command
   my $cmdlength = scalar(@fqc_char);                           # record the length.

   # set the input buffer to the replacement command

   @$ib = @fqc_char;

   # here we use the length of the current command line
   # and prepend backspaces to the pending command to whack it.

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, "\b";    # prepend a backspace for sending to the terminal
   }

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, " ";     # prepend a backspace for sending to the terminal
   }

   for ( my $n = 0 ; $n < $ibl ; $n++ ) {
      unshift @fqc_char, "\b";    # prepend a backspace for sending to the terminal
   }

   # then we write it to the CLI

   my $string = join "", @fqc_char;

   $self->writelock(1);
   $self->sw($string);            # string write
   $self->writelock(0);

   return undef;
}

## HERE
#

sub uparrow {
   my $self = shift;
   my $h    = $self->gethistline(1);
}

#

sub downarrow {
   my $self = shift;
   my $h    = $self->gethistline(0);
}

sub appendhistory {    #
   my $self = shift;
   my $line = shift;

   # We don't append blank lines

   return undef unless $line =~ /\w+/;

   # add the current line to the history

   unshift @{ $self->{'_cmdhist'} }, $line;
   shift @{ $self->{'_cmdhist'} } if scalar( @{ $self->{'_cmdhist'} } ) > $HISTLG;

   return undef;
}

# srl serial read line. This is a a character by character reader that eventually
# aggregates a line of command input. It includes output locks, and does command
# autocompletion.

sub srl {    # serial read line (NEW)
   my $self  = shift;
   my $class = ref($self);

   my $S  = $self->{'TTYR'};       # Serial Port Read Handle
   my $ib = $self->{'_input'};     # input buffer accumulates as we type
   my $db = $self->{'_divert'};    # accumulates input while we are outputting
   my $ob = $self->{'_output'};    # buffer from which we print

   # seeing a hit and miss terminal behavior? You have two instances running on
   # the same serial port, you silly person.

   my $c;      # an input character from the terminal
   my $ibl;    # current input buffer length
   my $dbl;

   $c   = getc($S);
   $ibl = scalar(@$ib);    # input buffer length
   $dbl = scalar(@$db);    # diversion buffer length

   # if a long report is being printed, we divert terminal type
   # to a buffer. If we get a character but the buffer is waiting, we
   # fifo. If no input character is waiting, we just read the buffer
   # down to zero as if it had been just typed.

   if ( $self->writelock() ) {    # we are currently printing something long

      if ( length($c) && $dbl < 200 ) {    # we buffer 200 characters of terminal input during write locks
         push @$db, $c;
         $dbl++;
      }

      return ( undef, $ibl );

   } else {

      if ( length($c) && $dbl ) {          # got a character and there is diverted data

         push @$db, $c;                    # current on top
         $c = pop @$db;                    # replace from bottom

      } elsif ( length($c) == 0 && $dbl ) {    # no character but buffer pending

         $c = pop @$db;                        # current from bottom
         $dbl--;                               # decrement the buffer counter

      } elsif ( length($c) == 0 && $dbl == 0 ) {    # no input character no buffer

         return ( undef, $ibl );

      }

      # from here we have one character, which is either from the diversion
      # buffer or directly from the terminal input.

      if ( $c =~ /$BCKSPC/ ) {    # backspace

         # warn $class::SNDEOL, "BCKSPC", $class::SNDEOL if $::_DEBUG_CHAR;

         if ( scalar(@$ib) ) {
            pop(@$ib);
            $ibl--;
            $self->sw("\b \b");
         }

         return ( undef, $ibl );

         # if we are the beginning of a control sequence, or
         # in the midst of of accumulating one

      }
      if ( $c =~ /$class::CTRLSQ/ || scalar( @{ $self->{'_ctrlbf'} } ) ) {    # character sequence: 27,91,(65,66)

         # if we have a character in buffer, accumulate it.

         # warn "CTL";

         push( @{ $self->{'_ctrlbf'} }, $c ) if length($c);

         # if the accumulated buffer matches an arrow, run the respective method
         # clear the control character buffer, and return the modified text line.

         if (  $self->{'_ctrlbf'}->[ 0 ] eq $class::CTRLSQ
            && $self->{'_ctrlbf'}->[ 1 ] eq $class::HISTUP->[ 0 ]
            && $self->{'_ctrlbf'}->[ 2 ] eq $class::HISTUP->[ 1 ] )
         {
            $ibl = $self->uparrow($ib);    #
            $self->{'_ctrlbf'} = [];
            return ( undef, $ibl );
         } elsif ( $self->{'_ctrlbf'}->[ 0 ] eq $class::CTRLSQ
            && $self->{'_ctrlbf'}->[ 1 ] eq $class::HISTDN->[ 0 ]
            && $self->{'_ctrlbf'}->[ 2 ] eq $class::HISTDN->[ 1 ] )
         {
            $ibl = $self->downarrow($ib);    #
            $self->{'_ctrlbf'} = [];
            return ( undef, $ibl );
         }

         # waste the control buffer if we got a control sequence we do not yet understand.

         $self->{'_ctrlbf'} = [] if scalar( @{ $self->{'_ctrlbf'} } ) > 2;

         return ( undef, $ibl );             # return the command

      } elsif ( $ibl && $c =~ /$CTRLC/ ) {    # ctrl-c (break)

         # BUG, this is only working on a double control-c

         $ibl = $self->histblankline($ib);    #
         $self->{'_ctrlbf'} = [];
         return ( undef, $ibl );

      } elsif ( $ibl && $c =~ /$class::TABCPL/ ) {    # tab

         # warn "class::TABCPL", $class::SNDEOL if $::_DEBUG_CHAR;

         # tab complete may modify the viewable text string and the input buffer

         $ibl = $self->tabcomplete($ib);    #

         return ( undef, $ibl );

      } elsif ( $ibl && $c =~ /$class::RCVEOL/ ) {    #  a command and end of line

         warn "CMDclass::RCVEOL", $class::SNDEOL if $::_DEBUG_CHAR;

         # warn "CMDclass::RCVEOL", $class::SNDEOL;               #  if $::_DEBUG_CHAR ;

         my $line = join "", @$ib;                    # aggregate the input line.
         $self->sndeol();

         @$ib = ();                                   # clear the buffer
         $ibl = 0;                                    # clear the counter

         $self->appendhistory($line);                 # record the command
         $self->{'_histindex'} = 0;                   # home the history index

         return ( $line, undef );                     # return the command

      } elsif ( $c =~ /$class::RCVEOL/ ) {            #  blank and end of line

         warn "class::RCVEOL", $class::SNDEOL if $::_DEBUG_CHAR;

         # warn "class::RCVEOL", $class::SNDEOL;               #  if $::_DEBUG_CHAR ;

         $self->{'_histindex'} = 0;                   # home the history index

         $self->sndeol();
         $self->prompt();
         return ( undef, 0 );

      } else {

         warn "NORMAL:", $c, $class::SNDEOL if $::_DEBUG_CHAR;

         # warn "NORMAL:", $c, $class::SNDEOL;          #  if $::_DEBUG_CHAR ;

         push @$ib, $c;
         $ibl++;
         $self->sw($c);
         return ( undef, $ibl );    # typed single character

      }
   }
}

# srchar: blocking read single character function

sub srchar {                        # blocking serial read character
   my $self = shift;

   my $c;

   while (1) {

      $c = getc();
      return $c if length($c);

      sleep $SLPINT;
   }

}

sub nbchar {
   my $self = shift;
   my $c    = getc();
   return $c if length($c);
   return undef;
}

# (sw) serial write takes care of screen output buffering, and
# may be called with no arguments to flog any previously buffered
# data.

sub sw {    # serial write (NEW)
   my $self = shift;
   my $line = shift;

   my @text;    # character split $_
   my $ob = $self->{'_output'};    # output buffer
   my $S  = $self->{'TTYW'};       # Write IO::Handle

   # If we got something buffer it.

   if ( length($line) ) {
      @text = split( //, $line );
      push @$ob, @text;
   }

   my $wrote   = undef;            # a character was written flag
   my $waiting = scalar(@$ob);     # output buffer remaining

   return ( $wrote, $waiting ) unless $waiting;

   # write from the buffer to the serial port.

   my $wrote = undef;              # flag
   my $c     = shift(@$ob);        # character
   $waiting--;                     # decr buffer count

   select $S;
   $wrote = print $c ;             # nonblocking.

   sleep $SLPINT if $::_DEBUG_CHAR;

   if ( $waiting > 20000 ) {       # emergency blow
      @$ob     = ();
      $waiting = 0;
      return ( 0, $waiting );
   }

   unless ($wrote) {               # no write possible
      unshift( @$ob, $c );         # put the char back
      $waiting++;
      return ( $wrote, $waiting );
   }

   return ( $wrote, scalar(@$ob) );
}

sub drainbuffer {                  # drain the write buffer
   my $self = shift;

   my $wrote;
   my $waiting;

   ( $wrote, $waiting ) = $self->sw();    # indevidual character write

   if ($waiting) {
      while ($waiting) {
         ( $wrote, $waiting ) = $self->sw();    # indevidual character write
      }
   }

   return $wrote;
}

sub prompt {                                    # configure or print prompt.
   my $self = shift;

   if ( length( $_[ 0 ] ) ) {
      $_[ 0 ] =~ s/\>$//g;
      $_[ 0 ] .= '>';
      $self->{'prompt'} = $_[ 0 ];
      return undef;
   }

   my $wrote;
   my $waiting;

   $self->writelock(1);

   $self->sndeol() if $_[ 1 ];    # shortcut prepend  an eol.

   if ( $self->{'modeflag'} ) {
      ( $wrote, $waiting ) = $self->sw( $self->{'modeprompt'} );
   } else {
      ( $wrote, $waiting ) = $self->sw( $self->{'prompt'} );
   }

   $self->writelock(0);

   return ( $wrote, $waiting );
}

sub escalateprompt {    # escalate/deescalate the prompt to display an interface mode
   my $self = shift;
   my $mode = shift;

   if ( length($mode) ) {
      $self->{'modeprompt'} = $mode;
      $self->{'modeflag'}   = 1;
      return 1;
   }

   $self->{'modeprompt'} = $self->{'prompt'};
   $self->{'modeflag'}   = 0;

   return 0;
}

sub prompttext {    #
   my $self = shift;
   return $self->{'prompt'};
}

sub cnf {           # command not found
   my $self = shift;
   $self->{'cnf'} = $_[ 0 ] if length( $_[ 0 ] );

   my $r;
   my $waiting;

   $self->writelock(1);

   $self->sndeol() if $_[ 1 ];
   ( $r, $waiting ) = $self->sw( $self->{'cnf'} );
   $self->sndeol() if $_[ 1 ];    # shortcut, prepend an eol

   $self->writelock(0);

   return ( $r, $waiting );
}

sub sCLOSE {                      #
   my $self = shift;
   $self->{'TTYR'}->close();
   $self->{'TTYW'}->close();
}

sub writelock {                   # set/get flag. Terminal read is buffering to accomidate a long screen write.
   my $self = shift;
   $self->{"_writelock"} = $_[ 0 ] if defined $_[ 0 ];
   return $self->{"_writelock"};
}

sub sndeol {                      # send an end of line.
   my $self = shift;
   $self->sw($class::SNDEOL);
}

sub clrscreen {                   #
   my $self = shift;

   # vt100 is 80x24
   # We need to print 24 lines,
   # and use printf to move the cursor to 0,0

   return undef;
}

1;
