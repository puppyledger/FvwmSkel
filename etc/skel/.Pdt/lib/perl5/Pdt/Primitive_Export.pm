package Pdt::Primitive_X;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# a simple exporter class header. use :r ! cbexport, and :r ! cbimport
# to automate header generation

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; # SKIPFACTORY (:P export)

#: <TMPL_VAR NAME=d_classdescription>

use Exporter ; 
our @ISA = qw(Exporter) ; 
our @EXPORT = qw(<TMPL_VAR NAME=b_exportmethodlist>) ; # (:C cbexport)
our %EXPORT_TAGS = ('all' => [qw(<TMPL_VAR NAME=b_exportmethodlist>)]) ; # (:C cbexport) 

use strict ; 

1 ; 
