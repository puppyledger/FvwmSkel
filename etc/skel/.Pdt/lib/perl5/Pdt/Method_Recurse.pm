package Pdt::Method_Recurse;

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::T;
push @ISA, qw(Pdt::T);
our @EXPORT = qw($T);
our $T;
use strict;
1;

# in template methods for multiple choice recursion
# at this time this just shows the form in template 
# though technically, it should be able to recurse 
# itself allowing for a looped query for subclass 
# bindings. 

__DATA__
sub <TMPL_VAR NAME=a_method_name>  {    # question dialog
   my $self = shift;
   my $R    = <<"MYDOCUMENT";
Pick one: 
a) example1           # 
b) example2           #    
MYDOCUMENT
   return $R;
}

sub _<TMPL_VAR NAME=a_method_name> {    # content processing
   my $self   = shift;
   my $letter = shift;
   my %fpairs = @_;

   chomp $letter;

   my $classmap = {
      'a' => 'Pdt::<TMPL_VAR NAME=b_class_rightmost_token>::Example1',
      'b' => 'Pdt::<TMPL_VAR NAME=b_class_rightmost_token>::Example2'
   };

   my $sc = $classmap->{$letter};
   return undef unless length($sc);

   my $ST;    # subtemplate
   my $r;     # report
   my $stblock = "use $sc\;";
   $stblock .= "\$ST \= $sc\-\>new\(\%fpairs\)\;";
   $stblock .= "\$r \= \$ST\-\>output\(\)\;";
   eval($stblock);

   return $@ if $@;

   return $r;
}
