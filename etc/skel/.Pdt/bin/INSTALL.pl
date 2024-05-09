#! /usr/bin/perl

my $VERSION = '2018-04-10.04-36-43.EDT';

use lib '../lib';

use Pdt::Install::Pdtdir qw(:all);    # .pdtdir text file
use Pdt::Install::Pdtrc qw(:all);     # .pdtrc text file
use Pdt::Install::Vimrc qw(:all);     # .vimrc text file
use Pdt::Install::Env;                # environment checking functions
use Pdt::Install::Bin;                # script modifying functions
use Pdt::Install::Lib;                # lib modifying functions

# HERE, modify M: here, to take text files by way of par.
# Then we should look at cbenv, to see if we can't integrate
# long questions into pdt.

use strict;

