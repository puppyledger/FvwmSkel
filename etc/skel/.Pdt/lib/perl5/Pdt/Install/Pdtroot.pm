package Pdt::Install::Pdtroot;
use Exporter;
our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

sub cbquestion {    # (:C cbquestion)
   my $self = shift;

   # callback map, generally run at constructor time only.
   # The cbmap program ignores methods matching:
   # ^_, ^do, ^cb, ^callback, ^new

   $self->{'cbquestion'} = {} unless ( ref( $self->{'cbquestion'} ) eq 'HASH' );
   $self->{'cbquestion'}->{'pdtroot'} = sub { shift; return $self->pdtroot(@_); };

   return ( $self->{'cbquestion'} );
}

sub pdtroot {    # pdtroot.txt

   my $encoded = <<"PDTROOT";
Pdt exists to manage many projects in parallel. All of your projects 
are kept in a single project root directory, and pdt installs in that 
project root directory as well. In this way pdt can be extended using 
its own tools.

It is recommended that pdt be installed per user, rather than as a 
system installation. This will allow the most flexibility for 
modifying pdt to work with various SCM systems. 

Typically project root is something like: 

\$HOME/Project

What would you like your project root directory to be? 
(environment variable expansion is enabled) 


PDTROOT

   return $encoded;
}

__DATA__
<TMPL_VAR NAME=pdtintro>
<TMPL_VAR NAME=pdtroot>
