package Pdt::Cbcmd ; use Exporter; our @ISA = qw(Exporter); use Pdt::L; 

# #
my $VERSION = '2018-04-13.07-03-59.EDT';

# This template is used to bulk load code callbacks for a variety of
# autolith type classes.

__DATA__ 
sub <TMPL_VAR NAME=execname> { # (:C <TMPL_VAR NAME=execname>)
	my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbcmd command matches only ^docmd.  

	$self->{'<TMPL_VAR NAME=mapname>'} = {} unless (ref($self->{'<TMPL_VAR NAME=mapname>'}) eq 'HASH') ;
	<TMPL_VAR NAME=mapstatement>

	return ($self->{'<TMPL_VAR NAME=mapname>'}) ;
}
