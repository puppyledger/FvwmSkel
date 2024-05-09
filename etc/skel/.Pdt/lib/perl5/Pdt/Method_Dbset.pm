package Pdt::Method_Dbset; # Method_Dbset (:M dbset)

#: this is a set of base methods for table and record 
#: upkeep for a simple records type table.  

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;

sub uc_name { # direct call from method_here
	my $self = shift ; 
	my $n = shift  ; 
	my $u = $n ; 
	$u =~ tr/a-z/A-Z/; 
	return ($u)
}

# TAG: <TMPL_VAR NAME=d_name> 

1;

__DATA__ 

sub _create_table {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}
sub create_table {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME  ;  # use this class table
	my $createtabletext = <TMPL_VAR NAME=a_create_table_here_funcname>() ; 
	#next
}

sub _drop_table {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub drop_table {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	
	#next
}

sub _add_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub add_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub _delete_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub delete_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub _select_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub select_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub _update_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

sub update_record {
	my $self = shift ; 
	my $T = $SQL_TABLE_NAME ;  # use this class table
	#next
}

1; 
