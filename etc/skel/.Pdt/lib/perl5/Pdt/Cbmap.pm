package Pdt::Cbmap;

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
	my $c = shift ; # class the method is in. (makes doc aggregation easier) 

	my $cbline = '$self->{\'' . 'cbmap' . '\'}->{\'' . $m . '\'} = sub { shift ; return $self->' . $m . '(@_) ; }' . ';' . '# ' . $c ;

	return $cbline ; 
}

1;

# This template is used to bulk load code callbacks for a variety of
# autolith type classes.

__DATA__ 
sub <TMPL_VAR NAME=execname> { # (:C <TMPL_VAR NAME=execname>)
	my $self = shift;

	# callback map, generally run at constructor time only.
	# The <TMPL_VAR NAME=execname> code generator ignores methods 
	# matching: 
	# ^_, ^do, ^cb, ^callback, ^new

	$self->{'<TMPL_VAR NAME=mapname>'} = {} unless (ref($self->{'<TMPL_VAR NAME=mapname>'}) eq 'HASH') ;
	<TMPL_VAR NAME=mapstatement>

	return ($self->{'<TMPL_VAR NAME=mapname>'}) ;
}
