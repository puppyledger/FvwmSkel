package Pdt::Primitive_T;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: A template that makes templates

# cbenv: insert environment variables into templates without asking questions.

sub cbenv {    # Map uppercase ENV variables to lowercase template variables
   my $self = shift;
   my @ev   = qw(example_template_variable);
   return @ev;
}

__DATA__ 
package <TMPL_VAR NAME=a_fullpackagename> ; use Exporter; our @ISA = qw(Exporter); use Pdt::L;
push @ISA, qw(Pdt::L); our @EXPORT = qw($T); our $T; use strict ; 1; 

#: Variable formats: <TMPL_VAR NAME=example_template_variable>  

__DATA__ 
