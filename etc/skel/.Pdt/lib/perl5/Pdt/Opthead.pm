package Pdt::Opthead ; 

#: many programs in Pdt (callback and method generators etc) use a common  
#: set of input options. Generally all of their normal operations happen 
#: from within VI and they know their editable file as ENV{'LASTEDITFILE'}
#: BUT, in order to troubleshoot it is neccessary to be able to hand 
#: this on the CLI. This class contains common option input headers 
#: for these programs so they can behave and troubleshoot uniformly. 
#: 

use Getopt::Std ;
use Bash::Sugar; 
use strict ; 

sub new {
	return (bless(\{},$_[0])) ; 
}

sub opthead1 { # know your editable file by -f -c or $ENV{'LASTEDITFILE'}
	my $self = shift ; 

	my $_DEBUG = 1 if ($_[0]) ; 

	my %OPTS;
	getopts( 'c:f:h', \%OPTS ); # class, or file, or help.

	&dohelp if $OPTS{'h'} ;

### get the currently edited file and the currently edited class

	my $BSUGAR = Bash::Sugar->new(); 
	$BSUGAR->sourceenv("$ENV{'HOME'}/.pdtrc");

	my $efn ; # edit file name
	my $ecl ; # edit class

	if (length($OPTS{'f'})) { # if we are passed a file get the class
        $efn = $OPTS{'f'} ; # may be relative
        $ecl = $BSUGAR->fn2class($efn) ; 
        $efn = $ENV{'PDT_LIB_PATH'} . "/" . $BSUGAR->class2fn($ecl) ; # no longer relative
        if ($_DEBUG) { warn "file from f: $efn" ; sleep 1 ; }
	} elsif (length($OPTS{'c'})) {  # if we are passed a class get the file
        $ecl = $OPTS{'c'} ; 
        $efn = $ENV{'PDT_LIB_PATH'} . "/" . $BSUGAR->class2fn($ecl) ; 
        if ($_DEBUG) { warn "file from c: $efn" ; sleep 1 ; }
	} else { # if not specified (normal) we are in VI. Use the environment variable defined in .vimrc
        $efn = $ENV{'LASTEDITFILE'} ; # may be relative
        $ecl = $BSUGAR->fn2class($efn) ; 
        $efn = $ENV{'PDT_LIB_PATH'} . "/" . $BSUGAR->class2fn($ecl) ; # no longer relative
        if ($_DEBUG) { warn "file from LASTEDITFILE: $efn" ; sleep 1 ; }
        if ($_DEBUG) { warn "write/read to RTFN: $ENV{'RTFN'}" ; sleep 1 ; }
	}

	my $tfn = $ENV{'RTFN'} ; 
	chomp $tfn ; 

	die ("edit file name undefined.") unless (length($efn)); 
	die ("edit class undefined.") unless (length($ecl)); 

	return($efn,$ecl,$tfn) ; 
}

# same as opthead1 but adds a flag for whether or not the proggy is in vim

sub opthead2 { # know your editable file by -f -c or $ENV{'LASTEDITFILE'}
	my $self = shift ; 

	my $_DEBUG = 1 if ($_[0]) ; 

	my %OPTS;
	getopts( 'c:f:h', \%OPTS ); # class, or file, or help.

	&dohelp if $OPTS{'h'} ;

### get the currently edited file and the currently edited class

	my $BSUGAR = Bash::Sugar->new(); 
	$BSUGAR->sourceenv("$ENV{'HOME'}/.pdtrc");

	my $efn ; # edit file name
	my $ecl ; # edit class
	my $vmm = 0 ; # flag designating vim mode 

	if (length($OPTS{'f'})) { # if we are passed a file get the class
        $efn = $OPTS{'f'} ; # may be relative
        $ecl = $BSUGAR->fn2class($efn) ; 
        $efn = $ENV{'PDT_LIB_PATH'} . "/" . $BSUGAR->class2fn($ecl) ; # no longer relative
        if ($_DEBUG) { warn "file from f: $efn" ; sleep 1 ; }
	} elsif (length($OPTS{'c'})) {  # if we are passed a class get the file
        $ecl = $OPTS{'c'} ; 
        $efn = $ENV{'PDT_LIB_PATH'} . "/" . $BSUGAR->class2fn($ecl) ; 
        if ($_DEBUG) { warn "file from c: $efn" ; sleep 1 ; }
	} else { # if not specified (normal) we are in VI. Use the environment variable defined in .vimrc
        $efn = $ENV{'LASTEDITFILE'} ; # may be relative
        $ecl = $BSUGAR->fn2class($efn) ; 
        $efn = $ENV{'PDT_LIB_PATH'} . "/" . $BSUGAR->class2fn($ecl) ; # no longer relative
		  $vmm = 1 ; 	
        if ($_DEBUG) { warn "file from LASTEDITFILE: $efn" ; sleep 1 ; }
        if ($_DEBUG) { warn "write/read to RTFN: $ENV{'RTFN'}" ; sleep 1 ; }
	}

	my $tfn = $ENV{'RTFN'} ; 
	chomp $tfn ; 

	die ("edit file name undefined.") unless (length($efn)); 
	die ("edit class undefined.") unless (length($ecl)); 

	return($efn,$ecl,$tfn,$vmm) ; 
}

1; 

