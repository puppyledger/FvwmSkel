package Pdt::Method_R; use Exporter; our @ISA = qw(Exporter); use Pdt::L; 

# #
my $VERSION = '2018-04-13.07-04-00.EDT';


# a template for formatting here document methods

__DATA__ 
sub <TMPL_VAR NAME=method> { # here document 
   my $self = shift;

   my $R = <<"MYDOCUMENT";

replace me with your text

MYDOCUMENT

	return $R ; 
}
