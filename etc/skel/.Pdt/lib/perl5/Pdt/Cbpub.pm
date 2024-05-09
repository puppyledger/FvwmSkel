package Pdt::Cbpub; use Exporter; our @ISA = qw(Exporter); use Pdt::L;

# #
my $VERSION = '2018-04-13.07-03-59.EDT';


# This template is used to bulk load code callbacks for a variety of
# autolith type classes.

__DATA__ 
sub <TMPL_VAR NAME=execname> { # (C: <TMPL_VAR NAME=execname>) 
   my $self = shift;

   # The cbpub command matches only ^docmd, and attempts to discern 
	# root level vs. escalated tokens automatically. Single token commands 
	# except those matching lowercase last-class-token, are assumed to be 
	# escalated. All others are assumed to be root level. YMMV

    my @api_public = (<TMPL_VAR NAME=mapstatement>)  ; # show command
    my @api_eepublic = (<TMPL_VAR NAME=escstatement>) ; # escalated show commands

    my @api_exec =  (<TMPL_VAR NAME=mapstatement>) ; # executable commands
    my @api_eexec = (<TMPL_VAR NAME=escstatement>) ; # escalated executable commands

	# publishapi is found in Cagix.pm

    return($self->publishapi(\@api_public,\@api_eepublic,\@api_exec,\@api_eexec)) ; 
}
