package Pdt::Uno_SetGet;

# this template requires a cli supplied method name
# it provides a cell accessor framework which prefers
# caching, but
# 

# #
my $VERSION = '2018-04-13.07-04-00.EDT';

our @ISA = qw(Exporter);
use Pdt::L;
push @ISA, qw(Pdt::L);
our @EXPORT = qw($T);
our $T;
use strict;
1;

#: Variable formats: <TMPL_VAR NAME=example_question>

__DATA__

	### :U setget <TMPL_VAR NAME=method_name> 

	def get<TMPL_VAR NAME=method_name>(self): # get the stringified property 
		if len(self.<TMPL_VAR NAME=method_name>): 
			return self.<TMPL_VAR NAME=method_name>
		else: 
			self.update<TMPL_VAR NAME=method_name>()
			return self.<TMPL_VAR NAME=method_name>

	def update<TMPL_VAR NAME=method_name>(self): # force an update of the stringified property
		self.set<TMPL_VAR NAME=method_name>cell() 
		self.<TMPL_VAR NAME=method_name> = self.get<TMPL_VAR NAME=method_name>cell().String

	def set<TMPL_VAR NAME=method_name>(self,<TMPL_VAR NAME=method_name>): # set a stringified property
			self.<TMPL_VAR NAME=method_name> = <TMPL_VAR NAME=method_name> 

	def get<TMPL_VAR NAME=method_name>cell(self): # get the cell handle
			return self.<TMPL_VAR NAME=method_name>cell

	def set<TMPL_VAR NAME=method_name>cell(self): # set the cell handle into the object
			cellid = self._cellname.get("<TMPL_VAR NAME=method_name>")
			self.<TMPL_VAR NAME=method_name>cell = self._sumsheet.getCellRangeByName(cellid)

