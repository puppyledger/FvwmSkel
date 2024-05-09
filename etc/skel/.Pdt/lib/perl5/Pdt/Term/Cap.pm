package Pdt::Term::Cap;    # EXPORTONLY (:P x)

#: Termcap Database

use Exporter;
our @ISA = qw(Exporter);

our (
   $BCKSPC,         $CTRLC,  $CTRLSQ, $HISTDN, $HISTLG, $HISTUP, $LINE_DATA_BITS, $LINE_PARITY, $LINE_SPEED,
   $LINE_STOP_BITS, $PROMPT, $RCVEOL, $SLPINT, $SNDEOL, $STRCNF, $TABCPL,         $TERMBL
);                         # (:C cbexport)
our @EXPORT =
  qw(settermcap termcap_minicom termcap_xterm $BCKSPC $CTRLC $CTRLSQ $HISTDN $HISTLG $HISTUP $LINE_DATA_BITS $LINE_PARITY $LINE_SPEED $LINE_STOP_BITS $PROMPT $RCVEOL $SLPINT $SNDEOL $STRCNF $TABCPL $TERMBL)
  ;                        # (:C cbexport)
our %EXPORT_TAGS = (
   'all' => [
      qw(settermcap termcap_minicom termcap_xterm $BCKSPC $CTRLC $CTRLSQ $HISTDN $HISTLG $HISTUP $LINE_DATA_BITS $LINE_PARITY $LINE_SPEED $LINE_STOP_BITS $PROMPT $RCVEOL $SLPINT $SNDEOL $STRCNF $TABCPL $TERMBL)
   ]
);                         # (:C cbexport)

sub settermcap {           # set terminal capabilities by pretty name
   my $self   = shift;
   my $tcname = shift;
   $tcname = 'termcap_' . $tcname;

   $foundit = 0;
   if ( ref( $self->{'cbmap'}->{$tcname} ) eq 'CODE' ) {
      &{ $self->{'cbmap'}->{$tcname} }( $self, @_ );
      $foundit++;
   }

   return $foundit;
}

sub termcap_xterm {    # we are connected to via an xterm
   my $self = shift;

   $SNDEOL = chr(015);    # CR
   $SNDEOL .= chr(012);   # LF
   $RCVEOL = chr(015);              # CR # "\n";
   $TABCPL = chr(9);
   $BCKSPC = chr(127);
   $TERMBL = "\a";
   $STRCNF = "Command Not Found";
   $PROMPT = ":";

   $CTRLSQ = chr(27);
   $HISTUP = [ chr(91), chr(65) ];
   $HISTDN = [ chr(91), chr(66) ];
   $HISTLG = 10;                     # History maxlength
   $CTRLC  = chr(3);
   $SLPINT = "0.001";

   # Control Sequences for arrow keys:
   # NSEW ^[[A ^[[B ^[[C ^[[D
}

sub termcap_minicom {    # we are connected to via minicom (by serving on a serial port)
   my $self = shift;

   $SNDEOL = "\015\012";             #
   $RCVEOL = "\n";                   #
   $TABCPL = "\t";                   #
   $BCKSPC = "\b";                   #
   $TERMBL = "\a";                   #
   $STRCNF = "Command Not Found";
   $PROMPT = "CAGIX>";
   $CTRLSQ = chr(27);
   $HISTUP = [ chr(91), chr(65) ];
   $HISTDN = [ chr(91), chr(66) ];
   $HISTLG = 10;                     # history length
   $CTRLC  = chr(3);
   $SLPINT = "0.001";

   $LINE_SPEED     = 9600;           # com port parameters
   $LINE_DATA_BITS = 8;
   $LINE_STOP_BITS = 1;
   $LINE_PARITY    = 0;
}

1;
