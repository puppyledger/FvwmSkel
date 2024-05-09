package Pdt::Fext;    # EXPORTONLY (:P x)

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT = qw(is_cpp is_pl is_pm is_py is_sh);                          # (:C cbexport)
our %EXPORT_TAGS = ( 'all' => [ qw(is_cpp is_pl is_pm is_py is_sh) ] );    # (:C cbexport)

use strict;

sub is_pl {
   my $fn = $_[ 0 ];
   return 1 if ( $fn =~ /\.pl/i );
   return 0;

}

sub is_pm {
   my $fn = $_[ 0 ];
   return 1 if ( $fn =~ /\.pm/i );
   return 0;
}

sub is_py {
   my $fn = $_[ 0 ];
   return 1 if ( $fn =~ /\.py/i );
   return 0;
}

sub is_sh {
   my $fn = $_[ 0 ];
   return 1 if ( $fn =~ /\.sh/i );
   return 0;
}

sub is_cpp {
   my $fn = $_[ 0 ];
   return 1 if ( $fn =~ /\.cpp/i );
   return 0;
}

1;
