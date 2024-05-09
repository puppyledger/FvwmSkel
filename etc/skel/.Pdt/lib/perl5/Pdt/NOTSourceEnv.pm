package Pdt::SourceEnv;    # EXPORTONLY

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

#: IDE environmental awareness functions

use File::Copy;
use Data::Dumper qw(Dumper);
use Pdt::SeePack qw(:all);
use Pdt::Bonk qw(:all);
use Exporter;
our @ISA = qw(Exporter);

# NOTE: DO NOT DELETE @EXPORT,
# as cbexport depends on this
# here package there, numbnuts.

our @EXPORT = qw(sourceenv class2fn class2bfn fn2class env2class rtfnorstdout bashexpand starexpand singlequote);
our %EXPORT_TAGS = ( 'all' => [ qw(sourceenv class2fn class2bfn fn2class env2class rtfnorstdout bashexpand starexpand singlequote) ] );

###

sub sourceenv {    # read our rc file into our environment variables
   my $fn = shift;

   # This is a total hack. This does the equivilent of a bash source command
   # DO NOT USE THIS WITH ANYTHING PRIVELEGED. YOU HAVE BEEN WARNED.

   my $VAR1;    # stub to pull in the bash environment

   unless ( -r $fn ) {
      warn "$fn not found.";
      return undef;
   }

   my $bashcode = "source $fn" . ';' . 'perl -MData::Dumper -e \'print Dumper \%ENV\'';

   # print "\n\n", $bashcode, "\n\n";
   eval qx{bash -c "$bashcode"};
   die($@) if $@;

   %ENV = %$VAR1;

   return 1;
}

sub class2fn {    # convert a class into a fully qualified filename
   my $class = shift;
   my $pdir  = $ENV{'PDT_LIB_PATH'};
   my $pext  = '.pm';
   $class =~ s/\:\:/\//g;
   my $fn = $pdir . '/' . $class . $pext;
   return $fn;
}

sub class2bfn {    # convert a class into a fully qualified backup filename
   my $class = shift;
   my $pdir  = shift;

   # if the user passes a path, use it instead

   $pdir = $ENV{'PDT_LIB_PATH'} unless length($pdir);

   my $pext      = '.pm';
   my $datestamp = `date +%F\.%H\-%M\-%S\.%Z`;
   chomp $datestamp;

   my @foo = split( /\:\:/, $class );
   my $fn = pop @foo;
   $fn = $fn . $pext . '.' . $datestamp;

   my @bar = split( /\//, $pdir );
   @foo = ( @bar, @foo, $fn );
   @bar = ();

   $fn = join "/", @foo;
   my $bfext = '.' . $datestamp;

   return ( $fn, $bfext );
}

sub fn2class {    # similar to seepack but more agnostic
   my $fn = shift;
   chomp $fn;

   # setbonk;
   # Bonk ($fn) ;

   my $failed = 0;

   open( FN, $fn ) || $failed++;
   my $line = readline(FN) || $failed++;
   close(FN);
   chomp $line;

   return undef unless ( $line =~ /package/ );

   $line =~ s/^\s*package\s*//;
   $line =~ s/\#.*$//;    # remove comments
   $line =~ s/\;.*//g;    # remove all but the package name
   $line =~ s/\s+//g;     # remove any dangling white space

   return $line;
}

sub env2class {           # get a list of classes, from environment variables AND/OR cli arguments.
   my $self = shift;

   my $LASTEDITCLASS;
   my @C;

   $LASTEDITCLASS = &seepack( $ENV{'LASTEDITFILE'} ) if length( $ENV{'LASTEDITFILE'} );

   push @C, $LASTEDITCLASS if length($LASTEDITCLASS);

   if ( scalar(@ARGV) ) {
      foreach (@ARGV) {
         chomp;
         push @C, $_;
      }
   }

   return @C if scalar(@C);

   return undef;
}

sub rtfnorstdout {    # if a random temp file name is defined, return it, otherwise return STDOUT
   my $OUTFH;

   unless ( length( $ENV{'RTFN'} ) ) {
      $OUTFH = *STDOUT;
   } else {

      # this is correct and should be an append. This allows
      # for batch scripts to all write to the same locale.

      open( OUTH, ">>$ENV{'RTFN'}" ) || die("can't write $ENV{'RTFN'}.");
      $OUTFH = *OUTH;
   }

   return $OUTFH;
}

sub bashexpand {    # expand bash variables in perl
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

sub starexpand {                  # expand trailing wildcard into an array of files
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

sub singlequote {    # normalize quotes on specified fields of an Pdt::L Object to be used to write an rc file.
   my $rctemplate = shift;

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

1;
