#! /Skel/bin/perl

# this script allows a character by character parsing of 
# escape characters, so that they can be anylized and then 
# copied. 

while (<STDIN>) {
	@foo = split(//, $_) ; 

	foreach (@foo) {
		my $o = ord($_) ; 
		my $c = chr($o) ; 
		# print $o, "\n" ; 
		print $o, "\t", $c, "\n"  ; 
	}

}
