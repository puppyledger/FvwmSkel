package Pdt::Primitive_Q;

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# This template is used by the pm script to create a fairly standardized module layout

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; # (P: q)

#: <TMPL_VAR NAME=brief_class_description>

use Pdt::O qw(:all) ; 
use <TMPL_VAR NAME=c_apiparentclass> ;
our @ISA = qw(<TMPL_VAR NAME=c_apiparentclass>) ; 

use strict ; 

our $SQL_TABLE_NAME = '<TMPL_VAR NAME=d_sql_table_name>' ;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift ; <TMPL_VAR NAME=a_fullpackagename>-><TMPL_VAR NAME=e_api_common_constructor_name>(@_) ; } 

# Our real constructors are name-common only within the API to prevent inheritance collision

sub <TMPL_VAR NAME=d_api_common_constructor_name> { 
	my $class = shift ; 

   my ($self, $start) = AUTOLITH($class) ; # object registration

   # interpolate the engines component classes 

   $self->AUTOPOPULATE(@_) ; 

   # map our exportable functions 

   if ($start) {

		# Note: 

		# the custom for this object is for prepare statements to be 
		# built in different functions. Prepare statement function 
		# names are preceded # with a "_", and cbprepare will 
		# automatically pick these up and run them at object creation 
		# time. This is intended to accelerate run time queries.  

		# $self->cbmap() ; # uncomment to enable standard callbacks
		# $self->cbprepare() ; # uncomment to enable startup prepares

   } else {

   	# runtime completeness checks 

	}

   # stack cleanup

   return $self ; 
}

### CALLBACKS

# :C cbprepare <additional classes> builds prepare callback map. 
# :C cbmap <additional classes> builds callback map. 

# sub cbmap { }

### METHODS 

# :M setget <method list> builds methods
# :M prepare 

1 ; 
