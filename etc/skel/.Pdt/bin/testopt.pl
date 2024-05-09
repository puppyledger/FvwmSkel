#! /usr/bin/perl

#: test the option header lib. You should get the same results whether you 
#: use -f -c or run from inside vim using a C or M macro

use Pdt::Opthead ; 
use Sort::Naturally qw(nsort);
use Pdt::SeePack qw(:all) ; 
use Bash::Sugar; 
# use Pdt::Cbmap; # now loaded by eval

use strict;

### input options (-f <filename> || -c <classname> || <none, LASTEDITFILE defined in .vimrc>)

my $_DEBUG = 0 ; 
my $OH = Pdt::Opthead->new() ; 
my ($efn,$ecl) = $OH->opthead1($_DEBUG) ; 

my $BSUGAR = Bash::Sugar->new(); 
$BSUGAR->sourceenv("$ENV{'HOME'}/.pdtrc");

print ("\n\nfile option: ", $efn, "\n") ; 
print ("\nclass option: ", $ecl, "\n") ; 
print ("\nargv: option: ", @ARGV, "\n") ; 

