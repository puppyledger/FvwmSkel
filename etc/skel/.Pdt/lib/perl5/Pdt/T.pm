package Pdt::T;    # Template Object

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

# DEPRECATED USE Pdt::L
# 2017-09-23 JMA

#: Autoloading autolithic template class for templates
#: stored in the __DATA__ handle.

my $VERSION = '3.5';

use Exporter;
use Data::Dumper;
use HTML::Template;

use Pdt::O qw(:all);
our @EXPORT = qw(AUTOLITH PLUROLITH DUMPREGISTRY COLLAPSE AUTOLOAD TEMPLATEHANDLE);
our %EXPORT_TAGS = ( 'all' => [ qw(AUTOLITH PLUROLITH DUMPREGISTRY COLLAPSE AUTOLOAD TEMPLATEHANDLE) ] );

our @ISA = qw(Pdt::O Exporter);

sub new {    # A fancy dynamic constructor
   my $class = shift;
   my ( $self, $start ) = AUTOLITH($class);    # registered objects
   my %param = @_;

   # METHOD MAP

   if ($start) {                               #
                                               # a template class has the ability to define a METHODMAP
                                               # function which may interpolate a series of coderefs
                                               # into $self, process or delete parameters before
                                               # they interpolate into object properties.
                                               #
                                               # If no function exists, then this just calls the
                                               # autoloader, and will thus leave a dangling property
                                               # "METHODMAP" which we delete.

      $self->METHODMAP( \%param );             # allow preprocessing
      delete $self->{'METHODMAP'};             # cleanup
   }

   # initially self is popuplated from the autoloader

   $self->AUTODISPATCH(%param);                # does not autoload

   if ($start) {
      $self->LOADTFH();
   }

   return $self;
}

sub TEMPLATEHANDLE {                           # accessor for a localized $__TEMPLATE__
   my $self  = shift;
   my $class = ref($self);

   # warn "TCR templatehandle: $class" ;

   if ( defined $_[ 0 ] ) {
      ${"$class\::__TEMPLATE__"} = shift;
      return 1;
   }

   return ${"$class\::__TEMPLATE__"};
}

sub LOADTFH {    # create the template handle from a localized __DATA__
   my $self  = shift;
   my $class = ref($self);

   my $startindex = 0;
   my $datahandle = *{"$class\::DATA"};

   tell($datahandle);
   seek( $datahandle, $startindex, 0 );

   my $eol = $/;    # store old end of line
   $/ = "__DATA__\n";    # set a new one

   my $modulecode   = readline($datahandle);
   my $templatecode = readline($datahandle);

   $/ = $eol;            # restore end of line

   close($datahandle);

   $modulecode = undef;

   my $handle = HTML::Template->new_scalar_ref( \$templatecode, 'die_on_bad_params' => 0, 'strict' => 0 );
   $handle->param(%$self);

   $templatecode = undef;

   $self->TEMPLATEHANDLE($handle);

   return 1;
}

sub EACHDISPATCH {    # return a hash pair, (from executed code if this is a method.)
   my $self = shift;
   my $k    = shift;
   my $v    = shift;

   if ( ref( $self->{$k} ) eq 'CODE' ) {
      my $V = $self->{$_}($v);
      return ( $k => $V );
   }

   $self->{$k} = $v if defined $k;
   return ( $k => $v );
}

sub output {    # return the populated template (passed vars execute on the fly)
   my $self  = shift;
   my $class = ref($self);

   my $T = $self->TEMPLATEHANDLE();

   # If there are arguments, the template
   # and ourselves are cleared. Local
   # dispatch is rerun and the template
   # is repopulated. Note that METHODMAP
   # is NOT rerun, since we should not
   # run autoload at any time except
   # startup.

   if ( scalar(@_) ) {
      %$self = {};
      $T->clear_params();
      $self->AUTODISPATCH(@_);    # does not autoload
      $T->param(%$self);
   }

   return $T->output();
}

sub fields {                      # return a property list
   my $self = shift;
   my $T    = $self->TEMPLATEHANDLE();
   return ( $T->param() );
}

sub clear {                       # clear all parameters from self and template. (deprecated)
   my $self = shift;

   my $T = $self->TEMPLATEHANDLE();

   # warn ("TCR clear: $self $T") ;

   %$self = {};
   $T->clear_params();

   return 1;
}

sub append {    # property update function
   my $self = shift;

   my $T = $self->TEMPLATEHANDLE();

   # warn ("TCR append: $self $T") ;

   if ( scalar(@_) ) {
      my %args = @_;
      my @k    = keys(%args);
      my $n    = 0;

      # additive only AUTODISPATCH

      foreach (@k) {
         $T->param( $self->EACHDISPATCH( $_ => $args{$_} ) );
         $n++;
      }

      return $n;
   }

   return 0;
}

sub insert {    # deprecated property update function
   my $self = shift;
   return $self->append(@_);
}

1;
