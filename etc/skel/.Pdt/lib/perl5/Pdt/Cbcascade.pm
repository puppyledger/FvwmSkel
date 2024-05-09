package Pdt::Cbcascade;

# #
my $VERSION = '2018-04-13.07-03-59.EDT';

# #
my $VERSION = '2018-04-13.07-02-33.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

1;

__DATA__ 
sub cbcascade { # (:C cbcascade) fieldname to class template cascade map
   my $self = shift ; 

	$self->{'cbcascade'} = {
		<TMPL_VAR NAME=fieldname_classname_hash_pairs>
	} ; 

	return ($self->{'cbcascade'}) ; 
}
