package Geo::UK::Postcode::Regex::Simple;

# VERSION

# ABSTRACT: Simplified interface to Geo::UK::Postcode::Regex

use strict;
use warnings;

use base 'Exporter';

use Geo::UK::Postcode::Regex;

our @EXPORT_OK = qw/ postcode_re /;

my $MODE     = 'strict'; # or valid or lax
my $ANCHORED = 1;
my $CAPTURES = 1;

sub postcode_re {



}






1;

