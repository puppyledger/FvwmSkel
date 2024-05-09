package Pdt::Method_Select;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

sub cbmap {    # (:C cbmap)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbmap'} = {} unless ( ref( $self->{'cbmap'} ) eq 'HASH' );
   $self->{'cbmap'}->{'SQL_STATEMENT'} = sub { shift; return $self->SQL_STATEMENT(@_); };

   return ( $self->{'cbmap'} );
}

# cbenv: insert environment variables into templates without asking questions.

sub cbenv {    # Map uppercase ENV variables to lowercase template variables
   my $self = shift;
   my @ev   = qw(SQL_STATEMENT);
   return @ev;
}

sub SQL_STATEMENT {    # localized preprocessing of environment sourced value
   my $self   = shift;
   my $string = shift;
   warn "reserved and preprocessed:", $string;
   return $string;
}

1;

__DATA__ 
sub <TMPL_VAR NAME=a_method_name> { # <TMPL_VAR NAME=e_method_brief_description> 
   my $self = shift ;
   
	my @rval = () ;  # _return values

	# @rval = $self->{'_<TMPL_VAR NAME=a_method_name>'}->execute() ; 
   
	return (@rval) ; 
}       

sub _<TMPL_VAR NAME=a_method_name> { # <TMPL_VAR NAME=sql_statement>     
   return $_[ 0 ]->{'_<TMPL_VAR NAME=a_method_name>'} unless $_[ 1 ];

   $_[ 0 ]->{'_<TMPL_VAR NAME=a_method_name>'} = $_[ 0 ]->{'db_handle'}->prepare(<TMPL_VAR NAME=sql_statement>) ;

	return 1 ; 
}
