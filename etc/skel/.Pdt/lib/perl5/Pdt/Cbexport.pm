package Pdt::Cbexport;

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;

use strict;

sub acceptname { # callback sets should be customarily name restricted
	my $self = shift ; 
   return 0 if ($_[0] =~ /^new/) ;     # ignore constructors
   return 0 if ($_[0] =~ /^cb/);       # specific to the CB class. cb's are API exports.
   return 0 if ($_[0] =~ /^callback/); # same as above
   return 0 if ($_[0] =~ /^do/);       # do's are local
   return 0 if ($_[0] =~ /^_/);        # _'s are private

	return 1; 
}

sub cbline { # generate an individual callback line for this type of callback
	my $self = shift ; 
	my $m = shift ; # method name
	return $m ; 
}

sub postprocess { # undo lines into a qw string stack
	my $self = shift ; 
	$self->{'mapstatement'} =~ s/\n\t/ /g ; 
	$self->{'mapstatement'} =~ s/^\s*// ; 
	$self->{'mapstatement'} =~ s/\s*$// ; 
}

1;

# This template is used to bulk load code callbacks for a variety of
# autolith type classes.

__DATA__ 

our @EXPORT = qw(<TMPL_VAR NAME=mapstatement>) ; # (:C cbexport)
our %EXPORT_TAGS = ('all' => [qw(<TMPL_VAR NAME=mapstatement>)]) ; # (:C cbexport) 

