#! /usr/bin/perl

# \#
my $VERSION = '2018-04-10.04-53-43.EDT';

use Term::ReadKey;
use Time::HiRes qw(sleep);
ReadMode 4;

use strict;

system "clear";
print "esc esc exits.\n";

my $p2b = 0;

while (1) {    #
   my $k = ReadKey(0);
   my $n = ord($k) if length($k);
   sleep(0.25);
   next unless ( length($n) );
   print "$k $n\n";

   $p2b++ if ( $n == 27 );
   die('exiting') if ( $n == 27 && $p2b );
}

