package Pdt::Method_Event;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: reference an existing function and turn it into an event

__DATA__
sub <TMPL_VAR NAME=method_name>event { # (:M event) 
	my $self = shift ; 

	# EVENT FORMAT:  [ window form widget pkey action redraw describe param ]

	my $window = undef ; 
	my $form = undef  ; 
	my $widget = undef ; 
	my $pkey = undef ; 

	my $action = sub { $self-><TMPL_VAR NAME=method_name>(@_) ; } ;   

	# redraw: undef does nothing, 0 ques redraw event, 1 flushes the redraw que

	my $formredraw = undef ; 

	my $describe = "\t<TMPL_VAR NAME=method_name>event: $self" ; 

	my @param = () ; 

	return(newevent($window, $form, $widget, $pkey, $action, $describe, @param)) ; 
}
