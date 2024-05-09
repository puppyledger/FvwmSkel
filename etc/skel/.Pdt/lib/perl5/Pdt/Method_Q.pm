package Pdt::Method_Q; use Exporter; our @ISA = qw(Exporter); use Pdt::L; 

# #
my $VERSION = '2018-04-13.07-04-00.EDT';


# Query Pair for Base::Q derived classes

__DATA__ 
sub <TMPL_VAR NAME=method> { # <TMPL_VAR NAME=description> 
	my $self = shift;
	$self->{'_<TMPL_VAR NAME=method>'}->execute(@_) ;
	my $hashref = $self->{'_<TMPL_VAR NAME=method>'}->fetchrow_hashref() ;
	return $hashref ; 
}       

sub _<TMPL_VAR NAME=method> { # <TMPL_VAR NAME=sql> 
	return $_[0]->{'_<TMPL_VAR NAME=method>'} unless $_[1] ;
	$_[0]->{'_<TMPL_VAR NAME=method>'} =  $_[0]->{'db_handle'}->prepare("<TMPL_VAR NAME=sql>") ;
	return 1 ; 
}

