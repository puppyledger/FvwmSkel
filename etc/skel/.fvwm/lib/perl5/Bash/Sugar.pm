package Bash::Sugar ; # EXPORTONLY

# a collection of one liners and system admin tools to make 
# living with bash suck less.  

use Cwd qw(abs_path) ; 
use Data::Dumper qw(Dumper) ;
use Time::localtime qw(localtime ctime) ; 
use Getopt::Std	; # CLI options
use File::Basename ;

use strict ; 

sub new { # 
	my $class = shift ; 
	return(bless(\{},$class)) ;  
}

#### Allow program and a stack of symlinks to use different parts of this lib

sub dobyexename { # map symlinks to methods 
	my $self = shift ; 

	&dohelp if ($ARGV[0] =~ /^\-\?/) ; 
	&dohelp if ($ARGV[0] =~ /^\-\h/) ; 

	my $exe = $0 ; 
	$exe =~ s/^.*\///g ; 
	chomp $exe ; 
	my $rv ; 
	my $runstr = '$rv = $self->' . $exe . '();' ; 
	eval($runstr) ; 

	if (length($@)) {
		print "$@\n" ; 
	}
}

sub sugar { # the sugar executable runs help if used directly 
	my $self = shift; 
	&dohelp; 
}

### Date/Time stamps (send 1 to be silent) 

sub isodate { # iso8601 date
	my $self = shift ; 
	my ($y,$M,$d,$h,$m,$s) = $self->gettime() ; 
	my $T = "$y\-$M\-$d" ; 
	return ($T) if scalar(@_);  # called /w any argument don't print
	print $T ; 
}

sub isotime { # iso8601 date_time
	my $self = shift ; 
	my ($y,$M,$d,$h,$m,$s) = $self->gettime() ; 
	my $T = "$y-$M-$d\_$h:$m:$s" ; 
	return ($T) if scalar(@_);  # called /w any argument don't print
	print $T; 
}

sub isothu { # iso8601 date_time_host_user (when, where, who) 
	my $self = shift ; 

	my $hostname = $self->gethostname() ; 
	my $user = $self->getuser() ; 

	my ($y,$M,$d,$h,$m,$s) = $self->gettime() ; 

	my $T = "$y:$M:$d\_$h:$m:$s\_$hostname\_$user" ;  

	if (scalar(@_)) {
		return $T ; 
	}

	print $T ; 
}

### Easy bash variable over method templating

### pipeline string tweakers 

sub pexp { # simple perl stream editor

	my $e = shift @ARGV ;
	die("must supply an expression") unless length($e) ;
	chomp $e;

	while (<STDIN>) {
   		my $block = '$_ =~ ' . $e . ';';
   		eval $block;
   		print $_ ;
	}
}

sub capstr { # capitalize the first character an argument, or all on STDIN 
	my $self = shift ; 

	if (length($_[0])) { # if we get arguments capitalize them 

			my $v = $_[0];
      	my @v = split( //, $v );
      	$v[ 0 ] =~ tr/a-z/A-Z/;
      	$v = join "", @v;
			return $v

	} elsif ( scalar(@ARGV) ) {    # capitalize one argument on the CLI
   		my $v = shift @ARGV;
   		chomp $v;
   		my @v = split( //, $v );
   		$v[ 0 ] =~ tr/a-z/A-Z/;
   		$v = join "", @v;
   		print $v ;

	} else {                  # Capitalize everything on STDIN
   		while (<STDIN>) {
      			my $v = $_;
      			my @v = split( //, $v );
      			$v[ 0 ] =~ tr/a-z/A-Z/;
      			$v = join "", @v;
      			print $v ;
   		}
	}
}

sub shoutstr { # capitalize the the whole argument, or all on STDIN
	my $self = shift ; 

	if (length($_[0])) { # if we get arguments shout them

		my $v = $_[0];
     	$v =~ tr/a-z/A-Z/;
		return $v

	} elsif ( scalar(@ARGV) ) {    # capitalize one argument on the CLI

   	my $v = shift @ARGV;
   	chomp $v;
   	$v =~ tr/a-z/A-Z/;
   	print $v;

	} else {                  # Capitalize everything on STDIN
   	while (<STDIN>) {
     		my $v = $_;
     		$v =~ tr/a-z/A-Z/;
     		print $v;
		}
	}
}

sub whisperstr { # lowercase a whole argument, or all on STDIN
	my $self = shift ; 	

	if (length($_[0])) { # if we get arguments shout them

			my $v = $_[0];
      	$v =~ tr/A-Z/a-z/;
			return $v

	} elsif ( scalar(@ARGV) ) {    # capitalize one argument on the CLI
   		my $v = shift @ARGV;
   		chomp $v;
   		$v =~ tr/A-Z/a-z/;
   		print $v ;
	} else {                  # Capitalize everything on STDIN
   		while (<STDIN>) {
      			my $v = $_;
      			$v =~ tr/A-Z/a-z/;
      			print $v ;
   		}
	}
}

### string-in-file-tweakers

sub chstring { # match & replace in file: chstring <filename> <oldstring> <newstring>
	my $self = shift ; 

	my $fn        = shift @ARGV;
	my $oldstring = shift @ARGV;
	my $newstring = shift @ARGV;

	chomp $fn;
	chomp $oldstring;
	chomp $newstring;

	die('usage: chstring <filename> <oldstring> <newstring>') unless ( length($fn) && length($oldstring) && length($newstring) );

	# generate a serialized backup extension

	my $fext;
	$fext = $self->isothu(1) ; 
	$fext = '.' . $fext;

	my $path = getcwd();    # get the path
	$path =~ s/\/$//g;      # get rid of trailing slash if one
	$path =~ s/$/\//;       # put one back

	# the filename from the CLI may have a partial path
	# so we split and reassemble.

	my $fqfn = $path . $fn; 				 # the fully qualified filename
	my @_fqfn = split( /\//, $fqfn );    # tokenize fully qualified filename
	$fn = pop(@_fqfn);                   # just filename portion
	my $bfn = '.' . $fn . $fext;         # serialized backup hidden filename

	$path = join '/', ( @_fqfn, undef ); # reassemble the path
	$fqfn = $path . $fn;                 # fully qualified filename
	my $fqbn = $path . $bfn;             # fully qualififed backup hidden filename

	# sanity check

	die('file does not exist: $fqfn') unless ( -e $fqfn );    #
	die('file is a directory: $fqfn') if ( -d $fqfn );        #

	print "changing $oldstring to $newstring in $fqfn" . ' [Y/n]';
	my $yn = <STDIN>;
	die("aborting") if $yn =~ /n/i;
	print "\n";

	rename( $fqfn, $fqbn ) || die("unable to rename $fqfn to $fqbn");
	open( OLD, "< $fqbn" ) || die("can't read $fqbn");
	open( NEW, "> $fqfn" ) || die("can't overwrite $fqfn");

	while (<OLD>) {
   		$_ =~ s/$oldstring/$newstring/g;
   		print NEW $_;
	}

	close(OLD);
	close(NEW);
}

sub chterp { # change the interpreter line: chterp <filename> <pathtoexecutable> (don't include shabang)
	my $self = shift ; 

	my $fn      = shift @ARGV;
	my $newterp = shift @ARGV;

	chomp $fn;
	chomp $newterp;

	unless ( length($fn) && length($newterp) ) { 
		die('usage: chterp <filename> <interpreterpath> \(note: don\'t include shabang\)\n')  ; 
	}  

	my $fext;
	$fext = $self->isothu(1) ; 

	my $path = getcwd();    # get the path
	$path =~ s/\/$//g;      # get rid of trailing slash if one
	$path =~ s/$/\//;       # put one back

	# the filename from the CLI may have a full or partial path
	# so we split and reassemble.

	my $fqfn = $fn;

	unless ( $fn =~ /^\// ) {
   		$fqfn = $path . $fn;
	}

	my @_fqfn = split( /\//, $fqfn );    # tokenize fully qualified filename
	$fn = pop(@_fqfn);                   # just filename portion
	my $bfn = '.' . $fn . $fext;         # serialized backup hidden filename

	$path = join '/', ( @_fqfn, undef ); # reassemble the path
	$fqfn = $path . $fn;                 # fully qualified filename
	my $fqbn = $path . $bfn;             # fully qualififed backup hidden filename

	# warn $fqfn ;

	open( FN, $fqfn ) || die("cannot open $fqfn");
	my $line = readline(FN) || die( "$fn", '... file not found.' );
	close(FN);
	chomp $line;
	die('not a script?') unless $line =~ /^\#\!/;

	$line =~ s/^\#\!//;                  #
	$line =~ s/\s+//g;                   #

	my $oldterp = $line;                 # The existing package:

	print "changing $oldterp to $newterp in $fqfn" . ' [Y/n]';
	my $yn = <STDIN>;
	die("aborting") if $yn =~ /n/i;
	print "\n";

	# FILE SWAP

	rename( $fqfn, $fqbn );

	open( OLD, "< $fqbn" ) || die("can't read file");
	open( NEW, "> $fqfn" ) || die("can't write file");

	while (<OLD>) {
   		$_ =~ s/$oldterp/$newterp/g;
   		print NEW $_;
	}

	close(OLD);
	close(NEW);
}

sub chpack { # change the "package" line: chpack <filename> <newpackname>
	my $self = shift ; 

	my $fn      = shift @ARGV;
	my $newpack = shift @ARGV;
	chomp $fn;
	chomp $newpack;

	die('usage: chpack <filename> <newpackagename>') unless $newpack =~ /\w+/;
	die('usage: chpack <filename> <newpackagename>') unless $fn =~ /\w+/;
	die("file is a directory: $fn") if ( -d $fn );

	my $path = getcwd();
	$path =~ s/\/$//g;    # get rid of trailing slash if one
	$path =~ s/$/\//;     # put one back
	$fn =~ s/^/$path/;    # prepend the path

	open( FN, $fn );
	my $line = readline(FN) || die( "$fn", '... file not found.' );
	close(FN);
	chomp $line;
	die('not a package?') unless $line =~ /package/;
	$line =~ s/^\s*package\s*//;
	$line =~ s/\#.*$//;    # remove comments
	$line =~ s/\;.*//g;    #  remove all but the package name
	$line =~ s/\s+//g;     #

	my $oldpack = $line;   # The existing package:

	print "changing $oldpack to $newpack" . ' [Y/n]';
	my $yn = <STDIN>;
	die("aborting") if $yn =~ /n/i;
	print "\n";

	# FILE SWAP
	my $r = rand();
	$r =~ s/\D//g;

	my $newfn = $fn . $r;

	open( OLD, "< $fn" )    || die("can't read file");
	open( NEW, "> $newfn" ) || die("can't write file");

	while (<OLD>) {
   		$_ =~ s/$oldpack/$newpack/g;
   		print NEW $_;
	}

	close(OLD);
	close(NEW);

	rename( $fn,    "$fn.orig" );
	rename( $newfn, $fn );

}
sub class2fn { # convert a perl class to a filename. class2fn <Foo::Bar>
	my $self = shift ; 
	my $fn = $self->pack2fn($_[0]) ; 
	return $fn ; 
}

sub class2bfn { # convert a perl class to hidden backup filename. class2bfn <brn> 

	my $self = shift ; my $cn ; 
	my $wascode = 0 ; 
		
	if (scalar(@_)) { 
		$cn = shift @_ ; 
		$wascode = 1 ; 
		chomp $cn ; 
	} else {
		$cn = shift @ARGV;
		chomp $cn;
	}

	my $fn = $self->pack2fn($cn); 
	my @_fn = split(/\//,$fn)	 ; 

	$_fn[-1] =~ s/^/\./ 			 ; 
	$fn = join ("\/",@_fn)		 ;  

	my $thu = $self->isothu(1)  ; 
	chomp $thu ; 

	my $bfn = $fn . "." . $thu  ; 

	return ($bfn) if ($wascode) ; 

	print $bfn; 
}

sub pack2fn { # convert a package line to a filename. pack2fn <package line>
	my $self = shift ; 
	my $pn ; 
	my $wascode = 0 ; 

	if (scalar(@_)) { 
		$pn = shift @_  ; 
		chomp $pn ; 
		$wascode = 1 ; 
	} else {
		$pn = shift @ARGV;
		chomp $pn;
	}

	$pn =~ s/^\s*package\s+// ; 
	$pn =~ s/\s*\;\s*$//g  ; 
	$pn =~ s/\:\:/\//g ; 
	$pn = $pn . "\.pm" ; 

	return ($pn) if ($wascode) ; 
	print $pn ; 

}

sub fn2pack { # convert a filename to a perl package line. fn2pack <filename>
	my $self = shift ; 
	my $fn ; 
	
	if (scalar(@_)) { 
		$fn = shift @_ ; 
		chomp $fn ; 
	} else {
		$fn = shift @ARGV;
		chomp $fn;
	}

	$self->fn2class($fn) ; 
	$fn =~ s/^/package / ;
	$fn =~ s/$/;/ ;

	print $fn ; 
	return $fn ; 
}

sub fn2class { # convert a filename to a perl class. fn2class <filename>
	my $self = shift ; 
	my $fn ; 
	my $wascode = 0 ;

	if (scalar(@_)) { 
		$fn = shift @_ ; 
		chomp $fn ; 
	 	$wascode = 1 ;
	} else {
		$fn = shift @ARGV;
		chomp $fn;
	}

	die ("$fn :  filename does not appear to be a .pm") unless ($fn =~ /\.pm$/i) ; 
	
	$fn = abs_path($fn) ; 
	# warn ("ABS FN:  $fn"); 

	$fn =~ s/\/perl\d\//\// ; 
	$fn =~ s/^.*\/lib\///g ; 
	$fn =~ s/\.pm$//i ; 	
	$fn =~ s/\//\:\:/g ; 

	# warn ("ABS CLASS:  $fn"); 

	return ($fn) if $wascode ; 
	print $fn ; 
}

### string in file viewers

sub seeclass { # display the perl class is a file. seeclass <filename>
	my $self = shift ; 
	my $fn 			  ; 
	my $wascode = 0 ;

	if (scalar(@_)) { 
		$fn = shift @_  ; 
		chomp $fn ; 
		$wascode = 1 ; 
	} else {
		$fn = shift @ARGV;
		chomp $fn;
	}

	# get and print the class ONLY

	my $cn = $self->showpack($fn) ; 
	return $cn if $wascode ; 
	return $cn ; 
}

sub showpack { # same as seeclass (both exist for compat) 
	my $self = shift ; 
	my $fn 			  ; 
	my $wascode = 0 ;

	if (scalar(@_)) { 
		$fn = shift @_  ; 
		chomp $fn  ; 
		$wascode = 1 ; 
	} else {
		$fn = shift @ARGV;
		chomp $fn;
	}

	open( FN, $fn ) || die ("showpack unable to open $fn");

	my $line ; 
	$line = readline(FN) || warn ("$fn has no length?");

	close(FN);
	chomp $line;

	warn ("$fn not a package?") unless ($line =~ /package/);

	$line =~ s/^\s*package\s*//;
	$line =~ s/\#.*$//;    # remove comments
	$line =~ s/\;.*//g;    #  remove all but the package name
	$line =~ s/\s+//g ;    #
	my $oldpack = $line;   # The classname but pulled from the package line

	if ($wascode) { # if called from code we return just the class
		return $oldpack ; 
	}else { # if called from the cli we return a "use statement" 
		print "$oldpack" ;
	}
}

sub seepack { # show the package line a perl package
	my $self = shift ; 
	my $fn 			  ; 
	my $wascode = 0 ;

	if (scalar(@_)) { 
		$fn = shift @_  ; 
		chomp $fn  ; 
		$wascode = 1 ; 
	} else {
		$fn = shift @ARGV;
		chomp $fn;
	}

	open( FN, $fn ) || die ("showpack unable to open $fn");

	my $line ; 
	$line = readline(FN) || warn ("$fn has no length?");

	close(FN);
	chomp $line;

	warn ("$fn not a package?") unless ($line =~ /package/);
	my $oldpack = $line;   # The classname but pulled from the package line

	if ($wascode) { # if called from code we return just the class
		return $oldpack ; 
	}else { # if called from the cli we return a "use statement" 
		print "$oldpack" ;
	}
}

sub seeterp { # show the interpreter line of a file
	my $self = shift ; 
	my $fn 			  ; 
	my $wascode = 0  ;

	if (scalar(@_)) { 
		$fn = shift @_ ; 
		chomp $fn  		; 
		$wascode = 1 	; 
	} else {
		$fn = shift @ARGV ;
		chomp $fn;
	}

	open( FN, $fn );

	my $line ; 
	$line = readline(FN) ;  
	close(FN);
	chomp $line;

	unless (length($line)) {
		warn ( "$fn", '... does not exist or file not found or has no length.' ) ; 
		return undef ; 
	}

	$line =~ s/^\#\!\s*// ;
	$line =~ s/$/ \# $fn/;

	unless ($wascode) {
		print $line ; 			
	}

	return($line) ;
}

sub showmethod { # see a particular perl method in file seemethod -f <filename> -m <method> -i [interior only]
	my $self = shift ; 

	my %OPTS;
	getopts( 'm:f:i', \%OPTS );
	my $method = $OPTS{'m'};
	my $fn     = $OPTS{'f'};
	chomp $method;
	chomp $fn;

	die('usage seemethod -f <filename> -m <methodname> -i interioronly') unless $fn =~ /\w+/;
	die('usage seemethod -f <filename> -m <methodname> -i interioronly') unless $method =~ /\w+/;

	open( FN, "$fn" ) || die("unable to open $fn");

	my $inmethod  = 0;
	my $isbracket = 0;

	while (<FN>) {
   		if ( $_ =~ /^sub\s+$method\s*\{/ ) {
      			$inmethod  = 1;
      			$isbracket = 1;

   		}
   		if ( $_ =~ /^\}/ && $inmethod ) {
      			$isbracket = 1;
  		}

   		if ( $inmethod && $isbracket ) { 
			print $_ unless $OPTS{'i'}; 
		} elsif ($inmethod) { 
			print $_ ; 
		}

   		if ( $_ =~ /^\}/ && $inmethod ) {
      			$inmethod = 0;
   		}

   		$isbracket = 0;
	}

	close(FN);
}

### trash strippers

sub crlf { # strip crlf from dos files. 
	my $self = shift ; 

	while (<STDIN>) {
		my $line = $_  ; 
   	$line =~ s/[\015\012]//g;    # strip CRLF
		$line = $line . "\n" ;
		print $line ; 
	}

}

sub addcrlf { # append crlfs to a file 
	my $self = shift; 

	while (<STDIN>) {
		my $line = $_ 	; 
		chomp $line 	; 
		$line . "\015" . "\012" ; 
		print $line ; 
	}

}

sub asciify { # strip UTF-8 garbage from web pastes
	my $self = shift ; 

	while (<STDIN>) {    
		my $line = $_ ; 
		$line =~ s/[[:^ascii:]]//g ; #
   		$line =~ s/[\015\012]//g;    # strip CRLF
		print $line ; 	
	}
}

### some dependent methods (shouldn't ever fail, but defined so if they do...) 

sub gettime { # get the current time params properly formatted
	my $self = shift ; 

	# there is a cleaner way, this is lazy

	my $y = localtime->year() + 1900; 
	my $M = localtime->mon() + 1; 
	my $d = localtime->mday(); 
	my $h = localtime->hour(); 
	my $m = localtime->min() ; 
	my $s = localtime->sec() ; 

	my @foo  = ($y, $M, $d, $h, $m, $s) ; 
	my $n = 0 ; 

	# always zero pad 

	foreach(@foo) {
		if (length($foo[$n]) < 2) {
			$foo[$n] = "0" . $foo[$n] ; 
		}
		$n++ ; 
	}

	return @foo ; 
}

sub getuser { #  the current working user
	my $self = shift ; 
	return $ENV{'USER'} ; 
}

### hostname and /etc/hosts processing

sub hostonly { # the current hostname 
	return($_[0]->gethostname()) ; 
}

sub gethostname { # maybe everything in the iso proggies should be in a lib? 
	my $self = shift ; 
        my $hostname = $ENV{'HOSTNAME'} ;

        # some perls are broken and don't see this env var, and the "hostname" command appears to detect
        # whether it is being run from a system call and exits with a 0 which shows on the screen.
        # so we just pipe it 

        unless (length($hostname)) {
                my $runstr = 'open (FOO, "hostname |");'  ;
                if (eval($runstr)) {
                        while(<FOO>) {
                                $hostname .= $_ ;
                                last ;
                        }
                }
        }

        close(FOO) ;

        # we may be running on a non-standard system (WTF?), try /etc/hostname

        unless (length($hostname)) {
                my $runstr = 'open (FOO, "/etc/hostname");'  ;
                if (eval($runstr)) {
                        while(<FOO>) {
                                $hostname .= $_ ;
                                $hostname =~ s/^.*\.*//g ; # truncate if fq
                                last ;
                        }
                }
	}

        close(FOO) ;

        chomp $hostname ;

        return $hostname ;
}

### Some stuff to help STDIN input seem more bashy

sub bashexpand { # ? incomplete ?
	my $self = shift ; 
   my $string = shift;

   chomp $string;
   $string =~ s/\s+//g;

   my $k = my $v = $string;

   # note that $v inserts a \ that escapes inside the following
   # string regex in the structure below. This is a bug in regexp?

   $v =~ s/^.*(\$\w+).*/\\$1/;    # variable
   $k =~ s/^.*\$(\w+).*/$1/;      # get the key element of the string
   my $e = $ENV{$k};

   if ( length($e) ) {
      $string =~ s/$v/$e/g;
   }

   return $string;
}

sub starexpand { # expand trailing * into a fully qualified array of files
	my $self = shift ; 
   my $string = shift;
   chomp $string;
   $string =~ s/\/\*$//;

   return () unless ( -d $string );
   opendir( DDIR, $string ) || die('unable to open directory $string');
   my @D = readdir(DDIR);
   close(DDIR);

   # prune hiddens

   for ( my $n = 0 ; $n < scalar(@D) ; $n++ ) {
      if ( $D[ $n ] =~ /^\./ ) {
         splice( @D, $n, 1 );
         $n--;
      }
   }

   # reformulate to fqfn

   for ( my $n = 0 ; $n < scalar(@D) ; $n++ ) {
      $D[ $n ] =~ s/^/$string\//;
   }

   return @D;
}

sub singlequote { # normalize quotes on specified fields of an Pdt::L Object to be used to write an rc file.
	my $self = shift ; 
   my $rctemplate = shift ;

   my @forcequote = qw(vtp_videogeom vtp_imagegeom);

   foreach my $v (@forcequote) {

      if ( length( $rctemplate->{$v} ) ) {

         # warn "requoting: ", $rctemplate->{$v} ;
         $rctemplate->{$v} =~ s/[\'\"]//g;
         $rctemplate->{$v} =~ s/^/\'/;
         $rctemplate->{$v} =~ s/$/\'/;
      }
   }

   return scalar(@forcequote);
}

#### Environment handling (perl only) 

sub sourceenv { # same as bash "source" but for perl
   my $self = shift; 
   my $fn = shift;

   my $VAR1 = {};       # Data::Dumper stub to pull in the bash environment

   unless ( -r $fn ) {
      warn "$fn not found.";
      return undef;
   }

   my $bashcode = "source $fn" . ';' . 'perl -MData::Dumper -e \'print Dumper \%ENV\'';

   eval qx{bash -c "$bashcode"};
   die($@) if $@;

   %ENV = %$VAR1;

   return 1;
}

sub sourceprefix { # same as above, but exclude all but a specified prefix
   my $self = shift	; 
   my $fn = shift	;
   my $prefix = shift 	;  

   my $VAR1;       # Data::Dumper stub to pull in the bash environment

   unless ( -r $fn ) {
      warn "$fn not found.";
      return undef;
   }

   my $bashcode = "source $fn" . ';' . 'perl -MData::Dumper -e \'print Dumper \%ENV\'';

   eval qx{bash -c "$bashcode"};
   die($@) if $@;

   foreach my $k (keys (%$VAR1)) {
	$ENV{$k} = $VAR1->{$k} if ($k =~ /^$prefix/) ;  
   }

   return 1;
}

sub envbyprefix { # grep environment variables by leading string 
	my $self = shift; 
   my $prefix = shift;

   my $extracted = {};

   foreach my $k ( keys %ENV ) {
      if ( $k =~ /^$prefix/ ) {
         $extracted->{$k} = $ENV{$k};
      }
   }

   return $extracted;
}

### temp file handling 

sub rtfn { # return a fully qualified unique time stamped temp file name. Expire it automatically. 
	my $self = shift ; 

	my $t = time();                      # epoch time.
	my $r = int( rand(1000000) + 1 );    # random number
	my $e = '.rtfn';                     # file extension
	my $p = "$ENV{'HOME'}" . "/.tmp" ;    # default tmp directory location
	my $x = 3600;                        # tmp files last an hour
	my $X = $t - $x;                     # expire cutoff

	$p = $ENV{'XTMPPATH'} if length( $ENV{'XTMPPATH'} );
	die ("user tmp directory $p does not exist. (rtfn)") unless (-d $p) ; 
	$x = $ENV{'XTMPEXPIRE'} if length( $ENV{'XTMPEXPIRE'} );

	$p =~ s/\/$//g;

	opendir(DH, $p ) || die("unable to open $p");

	my @old_tmps;

	foreach ( readdir(DH) ) {
   		next if $_ =~ /^\./;
   		next unless $_ =~ /^\d+\-\d+\.tmp/;
   		my $interval = $_;
   		$interval =~ s/\-.*//g;
   		if ( $interval < $X ) {
      			push @old_tmps, $_;
   		}
	}

	closedir(DH);

	foreach (@old_tmps) {
   		$_ = $p . '/' . $_;
   		# warn "expiring $_" ;
   		unlink $_;
	}

	my $rfn = $p . '/' . $t . '-' . $r . $e;

	return($rfn) if scalar(@_) ; 
	print $rfn ;
} 

#### command stackers

sub doeach { # take a stack of lines, and assume each one is bash command, run it. 
	my $self = shift ; 
	
	my $arg = shift @ARGV;
	chomp $arg;

	while (<STDIN>) {
   		next unless $_ =~ /\w+/;
   		chomp;
   		print "\n";
   		system($_) unless $arg =~ /\w+/;
	}

}

sub stackbash { # source one or multiple bash files and run the last one in the argument chain
	my $self = shift ; 

	my $runfn = pop(@ARGV) ; 
	chomp $runfn ; 

	foreach my $srcfn (@_) {
		$self->sourceenv($srcfn) ; 
	}

	system($runfn) ; 
}

### versioning

# these should take arguments, if a program wants to add
# something specific that should be in the program not in 
# the lib. These just check lines 3 and lines 4 for version 
# and copyright variables and replace/insert as appropriate.

sub versioninplace { # not yet implemented
	# see the pdt version of this
}

sub copyrightinplace { # not yet implemented

	# see the pdt version of version in plce. 
} 

### the help page

sub dohelp { # prints this file
   while (<DATA>) { print $_ ; }
   exit;
}

1 ; 

__DATA__

### Bash::Sugar README

Bash::Sugar is a collection of many utilities for file and 
environment management. Many of these are generic sysadmin 
utilities, but some are specific to managing perl projects. 
They can be divided up into formats, stream editors, file 
interrogators and file manipulation tools. 

What is different about Bash::Sugar, is that the programs 
are implemented both as perl methods, and as commands via 
simple symbolic links. This allows identical functionality 
when writing tools in perl, or in bash. 

Implementation of dual language functionality is by using 
symlinks to the included program "sugar", which acts as 
a method accessor. A symlink to the program "sugar" that 
is named the same as a method, will function by running 
the appropriate method. This is similar to how "busybox" 
works. 

Much of the impetus for these tools is the difficulty 
inherent to nesting data structures and escapes in Bash. 
By using the tools in Bash::Sugar you can quickly generate 
highly dynamic jobs in one command line statement. 


### EXAMPLE: 

Bash::Sugar has a few date formats based on ISO-8601
which are particularly useful for backups because 
they are self sorting. 

These are: 
"isodate", "isotime" and "isothu" (time host user).  

These exist both as perl methods: 

#! /bin/perl
my $S = Bash::Sugar->new()  ; 
print ("foo.", $S->isodate()) ; # prints foo.2022-12-31

And as shell commands: 

#!/bin/bash 
echo "foo\.`isodate`" # prints foo.2022-12-31

This works because the installer did this:  

/bin/ln -s sugar isodate 

### HOW TO USE 

A solid knowledge of the perl regexp bestiary (which is much 
better than the standard bestiaries in most programs) can 
allow you to achieve some interesting things. Included is 
the program 'pexp', which functions like sed -E. It just 
takes a regexp on the CLI and you can stack it as many 
times as you want: 

# example: 

ls | pexp 's/^/seeterp /' | doeach | grep perl | chterp '/usr/local/perl'

translation: 
for every file check the interpreter line, if it is perl change the 
intepreter line to the locally installed perl 

Many such small tools like this exist for moving files around different 
distros. This is useful for (at the moment) perl script, perl packages, 
bash and generic string match/replace replacement (chstring) 
  
# tmp files: 

Tmp files are still useful in the bash environment because we are 
often working with non-threading processes. Because of this 
we can use the program "rtfn", to generate a random temp file name.  
"rtfn" cleans up after itself autoexpiring old tmp files. This is 
handy for using with macros in external programs (see the .vimrc 
in FvwmSkel) as we can copy out and copy in data cleanly. 

### LIST OF METHODS (most are also programs)

new  # constructor
dobyexename  # map symlinks to methods 
sugar  # the sugar executable runs help if used directly 
isodate  # iso8601 date
isotime  # iso8601 date_time
isothu  # iso8601 date_time_host_user (when, where, who) 
pexp  # simple perl stream editor like sed -E
capstr  # capitalize the first character an argument, or all on STDIN 
shoutstr  # capitalize the the whole argument, or all on STDIN
whisperstr  # lowercase a whole argument, or all on STDIN
chstring  # match & replace in file: chstring <filename> <oldstring> <newstring>
chterp  # change the interpreter line: chterp <filename> <pathtoexecutable> (don't include shabang)
chpack  # change the "package" line: chpack <filename> <newpackname>
class2fn  # convert a perl class to a filename. class2fn <Foo::Bar>
class2bfn  # convert a perl class to hidden backup filename. class2bfn <Foo::Bar> 
pack2fn  # convert a package line to a filename. pack2fn <package line>
fn2pack  # convert a filename to a perl package line. fn2pack <filename>
fn2class  # convert a filename to a perl class. fn2class <filename>
seeclass  # display the perl class is a file. seeclass <filename>
showpack  # same as seeclass (both exist for compat) 
seepack  # show the package line a perl package
seeterp  # show the interpreter line of a file
showmethod  # see a particular perl method in file seemethod -f <filename> -m <method> -i [interior only]
crlf  # strip crlf from dos files. 
addcrlf  # append crlfs to a file (never used, does it work?)
asciify  # strip UTF-8 garbage from web pastes
gettime  # get the current time params properly formatted
getuser  #  the current working user
hostonly  # the current hostname  (corrects for often broken "hostname" commands)
gethostname  # maybe everything in the iso proggies should be in a lib? 
bashexpand  # ? incomplete ?
starexpand  # expand trailing * into a fully qualified array of files
singlequote  # normalize quotes on specified fields of an Pdt::L Object to be used to write an rc file.
sourceenv  # same as bash "source" but for perl
sourceprefix  # same as above, but exclude all but a specified prefix
envbyprefix   # grep environment variables by leading string 
rtfn  # return a fully qualified unique time stamped temp file name. Expire it automatically. 
doeach  # take a stack of lines, run each in an indevidual shell. (avoids ENV breakage)
stackbash  # source one or multiple bash files and run the last one in the argument chain
versioninplace    # inserts a dated version line in a file (waiting refactor) 
copyrightinplace  # inserts a copyright line in a file (waiting refactor) 
dohelp  # prints this file

### CONFIGURABLES 

The random temp file name tool is quite helpful in macros where 
files need to be edited before importation, such as in templating 
systems like Perl Development Templates. 

rtfn  # random temp file name (entropy: 1/1m per second) 

	rtfn prints fully qualified filenames which are 
	reliably unique for the purposes of generating 
	tmp files. rtfn also expires (deletes) old temp 
	files automatically. 

	there are two environment variables that can be 
	defined to change rtfn behavior: 

	XTMPATH 
	
	defines the location of your temp file 
	directory. ($HOME/.tmp is the default) If for 
	example you want your files to be place 
	in ~/Project/.tmp you can add the following to 
	your .bashrc or .xinitrc file: 

	export XTMPPATH=$HOME/Project/.tmp

	XTMPEXPIRE

	defines the length of time (in seconds) to 
	wait before expiring old temp files. This 
	value is set to one hour (3600) by default. 
	So for example if you wanted to make the 
	expire interval two hours you can add the 
	following to your .bashrc file: 

	export XTMPEXPIRE=7200


