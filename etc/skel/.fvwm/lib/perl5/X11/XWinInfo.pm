package X11::XWinInfo;

# usage: my $window = X11::XWinInfo->new(<id>) ;
#
# if <id> is not supplied then the currently focused
# window will be used.
#
# parse the properties from the xwininfo program into
# a perl object. \s and - are transposed with _ and
# the textual names are all lowercase. Methods are
# AUTOLOAD set/gets. So future changes to xwininfo's
# output will be reflected in this objects methods
# and properties  without any changes to its code.
# YYMV.
#

sub new {    # get xwininfo from a windowid
   my $class = shift;
   my $self = bless {}, $class;
   $self->thiswindow(@_) if scalar(@_);
   return $self;
}

sub newdesk {    # get xwininfo for the whole desktop
   my $class = shift;
   my $self = bless {}, $class;
   $self->parsexdeskinfo();
   return $self;
}

sub thiswindow {    # determine the windowid
   my $self = shift;
   my $id;

   # use passed window id if supplied, use the environment variable if not,
   # and accept either decimal or hex windowid's ;

   $id = $_[ 0 ] if length( $_[ 0 ] );
   $id = $ENV{'WINDOWID'} unless length($id);
   $id = sprintf( "0x%x", $id ) unless $id =~ /x/i;

   $self->{'windowid'}     = $id;
   $self->{'windowid_int'} = $ENV{'WINDOWID'};

   $self->parsexwininfo($id);
}

sub parsexwininfo {    #
   my $self = shift;
   my $id   = shift;

   # warn $self ;

   open( XWININFO, "xwininfo -id $id |" ) || die("no xwininfo. check your PATH");

   while (<XWININFO>) {

      # get rid of white space in all the wrong places.

      chomp;
      $_ =~ s/^\s+//g;
      $_ =~ s/\s+$//g;
      next unless length($_);

      # converts -geometry to geometry:

      $_ =~ s/^\-(\w+)\s+/$1\:/;

      my ( $k, $v ) = split( /:/, $_ );    # splits key:value

      $k =~ s/\s+$//;
      $v =~ s/^\s+//;

      # here we convert the keys to all lower property names with underscores instead of
      # hyphens so we may match up method names if so inclined.

      $k =~ s/[\s+\-]/\_/g;
      $k =~ tr/A-Z/a-z/;

      $self->{$k} = $v;

   }
}

sub parsexdeskinfo {    #
   my $self = shift;
   my $id   = shift;

   # warn $self ;

   open( XWININFO, "xwininfo -root |" ) || die("no xwininfo. check your PATH");

   while (<XWININFO>) {

      # get rid of white space in all the wrong places.

      chomp;
      $_ =~ s/^\s+//g;
      $_ =~ s/\s+$//g;
      next unless length($_);

      # converts -geometry to geometry:

      $_ =~ s/^\-(\w+)\s+/$1\:/;

      my ( $k, $v ) = split( /:/, $_ );    # splits key:value

      $k =~ s/\s+$//;
      $v =~ s/^\s+//;

      # here we convert the keys to all lower property names with underscores instead of
      # hyphens so we may match up method names if so inclined.

      $k =~ s/[\s+\-]/\_/g;
      $k =~ tr/A-Z/a-z/;

      $self->{$k} = $v;
   }
}

sub printkey {    # show all the keys that xwininfo gave us.
   my $self = shift;
   my @foo = join "\n", ( "", keys(%$self), "", "" );
   print @foo;
}

sub xwingeom {    # X11 geometry string by X11 windowid
   my $self = shift;

   my $sizex   = _makeeven( $self->width() );
   my $sizey   = _makeeven( $self->height() );
   my $offsetx = _makeeven( $self->absolute_upper_left_x() );
   my $offsety = _makeeven( $self->absolute_upper_left_y() );

   my $vidattrs = $sizex . 'x' . $sizey . '+' . $offsetx . '+' . $offsety;

   return $vidattrs;
}

sub anchorgeom {    # geometry string for specified resolution anchored top left.
   my $self   = shift;
   my $width  = shift;
   my $height = shift;

   my $offsetx = 0;
   my $offsety = 0;

   my $vidattrs = $width . 'x' . $height . '+' . $offsetx . '+' . $offsety;

   return $vidattrs;
}

sub rootgeom {    #
}

sub _makeeven {    # some codecs don't like odd window sizes
   my $v = shift;
   $v++ if ( $v % 2 );
   return $v;
}

sub AUTOLOAD {     # automatic set/get method
   my $self = shift;
   our $AUTOLOAD;    # what we spoofing

   my @tree        = split( /\:\:/, $AUTOLOAD );
   my $functioname = pop @tree;
   my $namespace   = pop @tree;

   return undef if $functioname eq "DESTROY";     # Destruction requires no action
   return undef if $functioname eq $namespace;    # Avoid recursion

   warn "AUTOLOAD: namespace, functioname: ", $namespace, ",", $functioname if $::_DEBUGAUTOLOAD;

   # simple set/get, true if set, value if exist, undef if neither

   if ( defined $_[ 0 ] ) {                       # passed variables interpolate
      $self->{$functioname} = $_[ 0 ];
      return 1;
   }

   return $self->{$functioname};
}

1;
