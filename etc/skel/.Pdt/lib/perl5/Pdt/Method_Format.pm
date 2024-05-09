package Pdt::Method_Format;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

1;

__DATA__ 
sub <TMPL_VAR NAME=a_methodname> { # <TMPL_VAR NAME=e_method_brief_description> 
   my @E    = @_;                # Entry::Ether objects

# NOTE: below, there can be no whitespace leading the line 
# terminator: SWRITE.  The swrite method is inherited from Pdt::O. 
# $SNDEOL should be globally defined with your localized cr/crlf 
# EOL character string.  

my $R .= $self->swrite( <<'SWRITE', @$E );
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< 
SWRITE

$R =~ s/^\s+\n//g; # truncate blank lines 
$R = "\n" . $R; # give us a leading return
$R =~ s/\n/$SNDEOL/g;

return $R;
}
