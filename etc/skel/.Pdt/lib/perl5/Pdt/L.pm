package Pdt::L;    # WebSuite BaseClass Template

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

# No autoloading, except pumping variables into templates

use HTML::Template;
use Data::Dumper qw(Dumper);
use Pdt::Bonk qw(:all);

# I think there is a good reason we don't derive here,
# but I forgot what it was.

use Pdt::O qw(:all);    # AUTOLITH

my $VERSION = '2.2';
use strict;

my $_DEBUG = 0;

our $T ; 

sub new { # 
   my $class = shift;
   my %foo   = @_;

   my $Tref;            # reference to a class wide $T

   my $useblock = 'use ' . $class . ' qw($T);';
   eval $useblock;

   my $refblock = '$Tref =  \$' . $class . '::T;';
   eval $refblock;

   # constructor

   my ( $self, $start ) = AUTOLITH($class);
   %$self = %foo;
   %foo   = {};

   # we only load the full template text on the first run.
   # we also only run the _init() function speculatively
   # on the first run.

   if ($start) {
      my $initblock = '$self->_init();';
      eval $initblock;

      # this die can be uncommented to catch bad initialization
      # code but ALWAYS turn it back off, as it breaks the whole
      # API

      # die($@) if ( $@ ) ;

      bonk "TEMPLATE", "\tPDTL initialized: ", $self, " ", $@;
   }

   $self->{'__TEMPLATE__'} = $Tref;

   # NOTE: loadfh must not b moved inside the start braces here.
   # it will break secondary runtime of the template.

   my $preload = $self->loadfh();

   return $self;
}

sub loadfh { # 
   my $self = shift;

   # Only load the DATA handle once.

   return (undef) if ( length( ${ $self->{'__TEMPLATE__'} } ) );

   my $class      = ref($self);
   my $startindex = 0;            # the beginning of the template file

   # We are duplicating the functionality of the DATA handle
   # here,by using seek. File indexes get hosed during
   # a fork. So we do it ourselves __DATA__ filehandle
   # for reliability.

   # First, set the fileindex to the beginning of the file,
   # and ignore whatever Perl thinks.

   my $tellblock = 'tell(' . $class . '::DATA);';

   eval($tellblock);
   warn( "TELL ERROR:", $@ ) if $@;

   my $seekblock = 'seek(' . $class . '::DATA, ' . $startindex . ',' . '0' . '); ';

   eval($seekblock);
   warn( "SEEK ERROR:", $@ ) if $@;

   # Next store the end of line character, and cycle the
   # file

   my $eol = $/;
   $/ = '__DATA__';

   my $content;    #
   my $stripblock = '$content = readline(' . $class . '::DATA' . ');';

   eval($stripblock);    # strips the preamble
   warn( "PREAMBLE ERROR:", $@ ) if $@;

   eval($stripblock);    # gets template content
   warn( "CONTENT ERROR:", $@ ) if $@;

   # strip the dangling end of line
   # and restore the end of line character

   $content =~ s/^\s*\n//;
   $/ = $eol;

   # close the filehandle

   my $closeblock = 'close(' . $class . '::DATA' . ');';

   eval($closeblock);
   warn( "CLOSE ERROR:", $@ ) if $@;

   # stick the content in a class wide variable

   my $setblock = '$' . $class . '::T' . ' = $content;';
   eval($setblock);
   warn( "PDTL SET ERROR:", $@ ) if $@;

   bonk "TEMPLATE", "\tPDTL template text read for: ", $class, " ", $@;

   undef $content;    # and pretend we were never here
}

sub output { # return the populated template
   my $self = shift;

   bonk "TEMPLATE", "PDTL self: ", $self;

   # die "PDTL self: ", $self, " ", $self->{'__TEMPLATE__'} ;

   my $Tref = delete $self->{'__TEMPLATE__'};

   bonk "TEMPLATE", "PDTL tref: ", $Tref;

   # die "TEMPLATE", "PDTL tref: ", $Tref ;

   # BUG: 2017-11-24, if called from within a local function,
   # processing stops here. This may be related to the nature
   # of the data, as the bug was detected with Pdt::Ascii,
   # or may be caused when called from _init, as _init is
   # eval'd code, so there may be a collision, or order
   # of precedence problem.

   my $t = HTML::Template->new_scalar_ref( $Tref, 'die_on_bad_params' => 0 );

   $t->clear_params();

   $t->param(%$self);

   $self->{'__TEMPLATE__'} = $Tref;

   return $t->output();
}

sub fields { # list the fields in the object
   my $self = shift;

   my $Tref = delete $self->{'__TEMPLATE__'};

   my $t = HTML::Template->new_scalar_ref( $Tref, die_on_bad_params => 0 );

   $t->clear_params();
   my @f = $t->param();

   $self->{'__TEMPLATE__'} = $Tref;

   return @f;
}

sub clear { # if one should choose to use the same object twice
   my $self = shift;
   my $Tref = delete $self->{'__TEMPLATE__'};
   my $n    = 0;
   foreach ( keys %$self ) {
      delete $self->{$_};
      $n++;
   }
   $self->{'__TEMPLATE__'} = $Tref;

   # reset any default properties

   my $initblock = '$self->_init();';
   eval $initblock;

   return $n;
}

sub clearfields { # clear without running init. Important if init constructs any pluroliths.
   my $self = shift;
   my $Tref = delete $self->{'__TEMPLATE__'};
   my $n    = 0;

   foreach ( keys %$self ) {
      delete $self->{$_};
      $n++;
   }

   $self->{'__TEMPLATE__'} = $Tref;
   return $n;
}

sub append { # change my properties after initialization
   my $self = shift;
   my %opts = @_;
   my $n    = 0;

   # if you are seeing drops of onesies and twosies here
   # your probably assuming that variable transliteration
   # goes from lower to upper as well as upper to lower.
   # it doesn't. If your keys are upper, pass them upper.
   # this may be a bug. ?

   foreach my $k ( keys %opts ) {

      # here we check if there is a callback method with the same name as the field.
      # if there is we run it with the value, if not we do a straight write.

      if ( ref( $self->{'cbmap'} ) eq "HASH" ) {
         if ( ref( $self->{'cbmap'}->{$k} ) eq "CODE" ) {
            &{ $self->{'cbmap'}->{$k} }( $opts{$k} );
            $n++;
            next;
         }
      }

      $self->{$k} = $opts{$k};
      $n++;
   }

   return $n;
}

sub appendcb { # experimental?  2017-11-07 (jma)
   my $self = shift;
}

sub insert { # alias for append (may be some anciet dependencies out there.)
   my $self = shift;
   $self->append(@_);
}

1;
