package Pdt::Install::Question;    # EXPORTONLY (:P x)

#: Here doc questions for the install.pl

use Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw(dbinstalled installpriv thiscpan);                     # (:C cbexport)
our %EXPORT_TAGS = ( 'all' => [ qw(dbinstalled installpriv thiscpan) ] );    # (:C cbexport)

use strict;

sub installpriv {                                                            # installpriv.txt

   my $encoded = <<"INSTALLPRIV";
                Welcome to Perl Development Tools (Pdt)

This installation dialog will ask questions and configure your installation.   

There are four phases to this installation.

        1. Installing PERL dependencies.  2. Installing Pdt.  3. Installing    
        or detecting database dependencies.  4. Installing or detecting other  
        program dependencies.                                                  

This installer will be using cpan to install additional packages. This will
require the same user privileges as perl, and an Internet connection.

Continue?  [Y/n]:
INSTALLPRIV

   return $encoded;
}

sub thiscpan {    # thiscpan.txt

   my $encoded = <<"THISCPAN";
I have discovered a cpan at: VAR1, i you would like to me use this cpan press  
return. If you have a localized cpan installed, please type the full path to   
that cpan:                                                                     
THISCPAN

   return $encoded;
}

sub dbinstalled {    # dbinstalled.txt

   my $encoded = <<"DBINSTALLED";
I have searched for an installed database application and found the following:

      Sqlite:  VAR1 Pg:  VAR2 Mysql:  VAR3

If you have not yet installed the database that you intend to use, it          
is recommended that you stop and do so now. In some cases the databases        
themselves may be required to to compile the respective DBD modules.           

Pdt will now attempt to install the DBI and the respective DBD packages any 
databases that have been found above.   

Continue? [y/N]
DBINSTALLED

   return $encoded;
}

1;
