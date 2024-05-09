package X11::ScreenRes;

#: container for some common screen resolutions.

use strict;

sub new {
   my $class = shift;

   my $self = {
      'VGA'   => [ 640,  480 ],
      '480P'  => [ 854,  480 ],
      '720P'  => [ 1280, 720 ],
      '1080P' => [ 1920, 1080 ]
   };

   bless $self, $class;
   return $self;
}

1;
