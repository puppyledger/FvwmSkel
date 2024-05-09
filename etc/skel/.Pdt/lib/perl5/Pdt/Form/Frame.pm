package Pdt::Form::Frame;    # (P: o)

# #
my $VERSION = '2018-04-22.10-27-42.EDT';

# #
my $VERSION = '2018-04-13.07-04-51.EDT';

#: Frame wrapper. Here we are taking advantage of the fact that callback
#: blocks are statically targeted. We can assume the identity of a template
#: by stealing its callbacks, and inserting an AUTOLOAD to catch any functions
#: and dump them through the callback map, which will then find the correct
#: dispatch for us.

use Pdt::O qw(:all);
use Pdt::Form::API;
use Pdt::Bonk qw(:all);

our @ISA = qw(Pdt::Form::API);

use strict;

### CONSTRUCTORS

# API sub classes, can be constructed independently with new()

sub new { shift; Pdt::Form::Frame->newframe(@_); }

sub newframe { # 
   my $class = shift;
   my %OPT   = @_;

   # bonk "FRAME", "\tNEWFRAME class template options: ", $class, " ", $OPT{'TEMPLATE'}, join ':', ( keys(%OPT) );

   my $self = bless \%OPT, $class;

   # use the template to generate our name

   my $tname  = ref( $self->{'TEMPLATE'} );
   my $_tname = $self->lowercaselastobject( $self->{'TEMPLATE'} );

   $self->FRAMENAME( $self->lowercaselastobject( $self->{'TEMPLATE'} ) );

   bonk "FRAME", "\tFRAMENAME from template: ", $tname, " ", $_tname, " ", $self->FRAMENAME();

   # run the templates callback table generator in its own namespace
   # then steal it. then run keyset and steal it.

   $self->{'TEMPLATE'}->cbmap();    #

   $self->{'cbmap'} = delete $self->{'TEMPLATE'}->{'cbmap'};

   # bonk "FRAME", "\tNEWFRAME callback map localized: ", $self->{'cbmap'};

   # run the templates keyset generator, then steal it.

   $self->{'KEYSET'} = $self->{'TEMPLATE'}->KEYSET();    # generate the keyset

   delete $self->{'TEMPLATE'}->{'KEYSET'};

   # bonk "FRAME", "\tNEWFRAME keyset localized: ", $self->{'KEYSET'};

   $self->initapi();

   return $self;
}

#### Pdt::Form::API

# these functions are polymorphic

sub isfocused {
   my $self = shift;
   return ( $self->isfocusedframe(@_) );
}

sub dropfocus {
   my $self = shift;
   return ( $self->dropframefocus(@_) );
}

sub takefocus {
   my $self = shift;
   return ( $self->takeframefocus(@_) );
}

sub focusnext {
   my $self = shift;
   return ( $self->focusnextframe(@_) );
}

sub focusprev {
   my $self = shift;
   return ( &focusprevframe(@_) );
}

#### DRAWING

# at the frame level, drawing just cascades to the form.

sub drawblank {
   my $self = shift;
   bonk "FRAME", "\tframe drawblank requested: ", $self;
   my $f = $self->FORM();
   return ( $f->drawblank() );
}

sub draw {
   my $self = shift;
   bonk "FRAME", "\tframe draw requested: ", $self;
   my $f = $self->FORM();
   return ( $f->draw() );
}

sub ALIGN {
   my $self = shift;
   bonk "FRAME", "\tframe ALIGN requested: ", $self;
   my $f = $self->FORM();
   return ( $f->ALIGN(@_) );
}

sub align {
   my $self = shift;
   bonk "FRAME", "\tframe align requested: ", $self;
   my $f = $self->FORM();
   return ( $f->align(@_) );
}

#### RELATED OBJECT HANDLING

# these are mostly populated by Pdt::Form::API::bootapi()

sub FORM { # (:M setget)
   my $self = shift;
   $self->{'FORM'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'FORM'};
}

sub FRAMENAME { # (:M setget)
   my $self = shift;
   $self->{'FRAMENAME'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'FRAMENAME'};
}

sub GEOM { # 
   return $_[ 0 ]->{'TEMPLATE'}->GEOM();
}

sub PARENTWINDOW { # (:M setget)
   my $self = shift;
   $self->{'PARENTWINDOW'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'PARENTWINDOW'};
}

sub TEMPLATE { # (:M setget)
   my $self = shift;
   $self->{'TEMPLATE'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'TEMPLATE'};
}

sub WIDGET { # (:M setget)
   my $self = shift;
   $self->{'WIDGET'} = $_[ 0 ] if ( defined $_[ 0 ] );
   return $self->{'WIDGET'};
}

sub output { # 
   my $self = shift;
   bonk "FRAME", "\tframe output.";
   my $TF = $self->TEMPLATE();
   return ( $TF->output(@_) );
}

sub fields {
   my $self = shift;
   my $TF   = $self->TEMPLATE();
   bonk "TEMPLATE", "\tTEMPLATE fields: ", $TF->fields();
}

#### TEMPLATE DISPATCH

# since we have stolen the cbmap from our template object,
# we can test it and call functions to populate the fields
# in the template.

#sub AUTOLOAD { #
#   my $self     = shift;
#   my $AUTOLOAD = shift;
#
#   bonk "FRAME", "22222222222222222222222222222", $AUTOLOAD;
#
#   my @tree = split( /\:\:/, $AUTOLOAD );
#
#   my $functioname = pop @tree;
#   my $namespace   = pop @tree;
#
#   bonk "FRAME", "FRAME AUTOLOAD: namespace, functioname: ", $namespace, ",", $functioname;    # if $::_DEBUGAUTOLOAD;
#
#   return undef if $functioname eq "DESTROY";                                                  # Destruction requires no action
#   return undef if $functioname eq $namespace;                                                 # Avoid recursion
#
#   # HERE, not sure if the inserted undef is required, but I think so.
#
#   if ( defined $self->{'cbmap'}->{$functioname} ) {
#      return ( &{ $self->{'cbmap'}->{$functioname} }( undef, @_ ) );
#   }
#
#   return undef;
#}

1;
