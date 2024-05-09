package Pdt::Form::API::Reg;    # EXPORTONLY (:P x)

# #
my $VERSION = '2018-04-13.07-05-04.EDT';

#: initial object registration functions required by Pdt::Form::API::bootapi

use Pdt::Bonk qw(:all);

use Exporter;
our @ISA = qw(Exporter);

our @EXPORT =
  qw(apiregisterform apiregisterframe apiregisterwidget apiregisterwindow lowercaselastobject lowercaselasttoken lowercasemastertoken);    # (:C cbexport)

our %EXPORT_TAGS =
  ( 'all' => [ qw(apiregisterform apiregisterframe apiregisterwidget apiregisterwindow lowercaselastobject lowercaselasttoken lowercasemastertoken) ] )
  ;                                                                                                                                        # (:C cbexport)

use strict;

sub apiregisterwindow { # initial object registration by Pdt::Form::API::bootapi()
   my $API   = shift;      # Pdt::Form::API
   my $W     = shift;
   my $order = shift;

   # bootapi should use lowercaselasttoken, to extract the objects
   # in the named order, and hand us the order with the object.

   return () unless ( defined $W );

   # window names are the same as frame names
   #
   # note: focus uses the lowercaselasttoken of the object, so we have no
   # need for the user defined name to mean anything.

   my $name = $W->WINDOWNAME();

   bonk "API", "\tAPI registering window: ", $W, " ", $name, " ", $order;

   $API->{'FOCUS'}->registerwindow(
      'windowobject' => $W,
      'windoworder'  => $order,
      'windowname'   => $name
   );

   return ();
}

sub apiregisterframe { # initial object registration by Pdt::Form::API::bootapi()
   my $API   = shift;
   my $F     = shift;
   my $order = shift;

   # bootapi just walks all frames as they come.

   return () unless ( defined $F );

   # frames and windows have correlating names

   my $name = lowercaselasttoken($F);

   # note: focus uses the lowercaselasttoken of the object, so we have no
   # need for the user defined name to mean anything.

   # Frames are factoried, but each grows a wrapper for itself during
   # its initial construction, due to the _init() function. We register
   # the wrapper, which allows us access to the both the template and
   # other neccessary funtions. Here we get the wrapper

   my $G = $F->GEOM();

   bonk "API", "\tAPI registering frame: ", $F, " ", $name, " ", $order;
   bonk "API", "\tAPI registering frame frame wrapper:", $G;

   $API->{'FOCUS'}->registerframe(
      'frameorder'  => $order,
      'frameobject' => $G,
      'framename'   => $name
   );

   return ();
}

# these take a whole different tack. The form and widget objects do
# an initapi() which gives them hooks into API. When Pdt::Form::new()
# is called, it should call out to:
#
# $self->{'PDTAPI'}->apiregisterform(%hash) ;
# $self->{'PDTAPI'}->apiregisterwidget(%hash) ;
#
# which comes here, and provides the same mechanism for populating
# into FOCUS as was previously in the new() function of Pdt::Form
#
# that should result in all of api registration being in one place.
#

sub apiregisterform { # (:M setget)
   my $API   = shift;
   my $W     = shift;    # window object
   my $F     = shift;    # template frame
   my $G     = shift;    # Pdt::Form::Frame
   my $f     = shift;    # Pdt::Form::form hash
   my $order = shift;

   return () unless ( defined $W && defined $F && defined $f );

   my $windowname = $W->WINDOWNAME();
   my $framename  = $G->FRAMENAME();
   my $formname   = $f->FORMNAME();

   my $formorder = $f->{'FORMORDER'};

   bonk "API", "\tapiregisterform: ", $API, " ", $W, " ", $F, " ", $G, " ", $f, " ", $order;

   $f->{'PARENTFRAME'}  = $G;
   $f->{'PARENTWINDOW'} = $W;

   $API->{'FOCUS'}->registerform(
      'windowobject' => $W,
      'windowname'   => $windowname,
      'frameobject'  => $G,
      'framename'    => $framename,
      'formobject'   => $f,
      'formname'     => $formname,
      'formorder'    => $formorder
   );

   return ();
}

sub apiregisterwidget { # (:M setget)
   my $API = shift;
   my $W   = shift;        # Pdt::Form::Window
   my $F   = shift;        # template
   my $G   = shift;        # Pdt::Form::Frame
   my $f   = shift;        # Pdt::Form::Form
   my $w   = shift;        # Pdt::Form::Widget

   my $windowname = $W->WINDOWNAME();
   my $framename  = $G->FRAMENAME();
   my $formname   = $f->FORMNAME();
   my $widgetname = $w->WIDGETNAME();

   bonk "API", "\tapiregisterwidget: ", $windowname, ":", $framename, ":", $formname, ":", $widgetname;

   my $formorder      = $f->{'FORMORDER'};
   my $widgetfullname = $w->{'ffullname'};
   my $widgetorder    = $w->{'ffocusorder'};

   # Here we link the widget field value, to the actual template values.
   # the frame is a template, and the fields in that template are used
   # to autoconfigure the widgets using formmap. Though we do check unless
   # something has been manually configured before registration.  (though
   # doing so will probably break rendering, but that is up to you)

   $w->{'fvalue'} = \$F->{$widgetfullname} unless ( defined $w->{'fvalue'} );

   $API->{'FOCUS'}->registerwidget(
      'windowobject' => $W,
      'windowname'   => $windowname,
      'frameobject'  => $G,
      'framename'    => $framename,
      'formobject'   => $f,
      'formname'     => $formname,
      'widgetobject' => $w,
      'widgetname'   => $widgetname,
      'widgetorder'  => $widgetorder
   );

   return ();
}

#### NAMING CONVENTIONS

sub lowercaselastobject { # get the last token name of another object
   my $self = shift;

   my $object = shift;
   my $class  = ( ref($object) );

   my @cltkn = split( /\:\:/, $class );
   my $name = pop(@cltkn);
   $name =~ tr/A-Z/a-z/;

   return $name;
}

sub lowercaselasttoken { # get the last token name of this object
   my $class = ref( $_[ 0 ] );
   my @cltkn = split( /\:\:/, $class );
   my $name  = pop(@cltkn);
   $name =~ tr/A-Z/a-z/;
   return $name;
}

sub lowercasemastertoken { # hand and object, get back the leading underscore delimited compinent of a class token
   my $lasttoken = &lowercaselasttoken(@_);
   my @foo = split( /_/, $lasttoken );
   return ( shift(@foo) );
}

1;
