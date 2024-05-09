package Pdt::Find;    # EXPORTONLY (:P x)

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

#: File finding tools for Pdt

use Cwd;
use File::Find;
use Exporter;
our @ISA         = qw(Exporter);
our @EXPORT      = qw(findininc findinpath);                     # (:C cbexport)
our %EXPORT_TAGS = ( 'all' => [ qw(findininc findinpath) ] );    # (:C cbexport)

use strict;

# take a hash, fn => undef, and fill it fn => fqfn
# for files found.

sub findinpath {                                                 # search our PATH for matching programs
   my $match = shift;

   my $P = $ENV{'PATH'};
   my @p = split( ':', $P );

   find(
      sub {
         foreach my $m ( keys(%$match) ) {
            if ( $_ eq $m ) {
               my $path  = cwd();
               my $found = "$path\/$_";
               print "$found\n";
               $match->{$m} = $found;
               next;
            }
         }
      },
      @p
   );

   return $match;
}

sub findininc {    # search perls @INC for classes
   my @match;

   my %found;
   foreach my $m (@match) {
      my $block = "use $m\;";
      eval $block;
      unless ($@) {
         $found{$m} = 1;
      } else {
         $found{$m} = 0;
      }
   }

   return \%found;
}

1;
