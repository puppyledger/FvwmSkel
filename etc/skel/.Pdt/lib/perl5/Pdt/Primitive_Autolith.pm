package Pdt::Primitive_Autolith;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# This template is used by the pm script to create a fairly standardized module layout

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; # (P: o)

#: <TMPL_VAR NAME=brief_class_description>

use Pdt::O qw(:all) ; 
use <TMPL_VAR NAME=c_apiparentclass> ;
our @ISA = qw(<TMPL_VAR NAME=c_apiparentclass>) ; 

use strict ; 

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift ; <TMPL_VAR NAME=a_fullpackagename>-><TMPL_VAR NAME=d_api_common_constructor_name>(@_) ; } 

# Our real constructors are name-common only within the API to prevent inheritance collision

sub <TMPL_VAR NAME=d_api_common_constructor_name> { 
	my $class = shift ; 

	# my %OPT = @_ ; 

   my ($self, $start) = AUTOLITH($class) ; # monolithic object 
   # my ($self, $start) = PLUROLITH($class) ; # record style object

	# take out anything that shouldn't get autoprocessed. 
	# $self->{'FOO'} = delete $OPT{'FOO'} if exists $OPT{'FOO'} ; 

   if ($start) { # A, true only on first run. P, always true

		# uncomment to enable callbacks
		# $self->cbmap() ; # create with C: cbmap

		# set defaults here

   } else {

   	# runtime completeness checks 

	}

	# anything not yet deleted autowrites to properties
   # $self->AUTOPOPULATE(%OPT) ; 

	# anything not yet deleted autoexecutes to methods, OR autowrites properties
   $self->AUTOMAP(@_) ; 

   return $self ; 
}

### CALLBACKS

# :C cbmap (builds cbmap automatically.) 
# sub cbmap { }

### METHODS 

# :M <yourmethod> (build methods from templates)

1 ; 
