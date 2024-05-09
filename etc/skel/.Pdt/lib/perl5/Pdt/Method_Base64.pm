package Pdt::Method_Base64;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

1;

__DATA__ 
sub <TMPL_VAR NAME=a_methodname> { # <TMPL_VAR NAME=e_method_brief_description> 
my $self = shift ;
my $R = <<"<TMPL_VAR NAME=b_herequotes_string>";
<TMPL_VAR NAME=c_base64_string>
<TMPL_VAR NAME=b_herequotes_string>
return (decode_base64($R));
}
