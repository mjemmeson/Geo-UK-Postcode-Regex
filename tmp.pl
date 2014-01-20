#!/usr/bin/perl

use lib 'lib';
use Tmp;

tie %h, 'Tmp';


 $h{a};


use Data::Dumper;
print Dumper(\%h);


