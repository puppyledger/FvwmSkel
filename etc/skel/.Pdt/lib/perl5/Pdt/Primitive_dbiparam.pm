package Pdt::Primitive_dbiparam;

# The dbi parameters are defined in their own EXPORTER class
# which the root query class imports by function call

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__
package <TMPL_VAR NAME=a_root_class>::Dbiparam ; # EXPORTONLY (:P x)

#: HERE documents for table creation

use Exporter ; 
our @ISA = qw(Exporter) ; 

our @EXPORT = qw(api_dbi_param) ; # (:C cbexport)
our %EXPORT_TAGS = ('all' => [qw(api_dbi_param)]) ; # (:C cbexport) 

sub api_dbi_param {
        my $D = {
        db_driver => undef,               # define the DBD class
        db_name   => undef,               # database name
        db_host   => undef,               # database host
        db_port   => undef,               # database tcp port
        db_user   => undef,               # database user
        db_pass   => undef,               # database pass
        db_str => undef                 # the combined DBI driver string.  (all of the above)
        } ; 

        return $D ; 
}

1; 

