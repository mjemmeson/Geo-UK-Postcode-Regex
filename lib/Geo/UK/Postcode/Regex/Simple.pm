package Geo::UK::Postcode::Regex::Simple;

# VERSION

# ABSTRACT: Simplified interface to Geo::UK::Postcode::Regex

use strict;
use warnings;

use Carp;

use base 'Exporter';

use Geo::UK::Postcode::Regex qw/ %REGEXES /;

our @EXPORT_OK = qw/ postcode_re /;

our $MODE     = 'strict'; # or valid or lax
our $PARTIAL  = 0;
our $ANCHORED = 1;
our $CAPTURES = 1;

sub postcode_re {

    croak "invalid mode" if $MODE !~ m/^(?:strict|lax|valid)$/;

    my $key = $MODE;
    $key .= '_partial'  if $PARTIAL;
    $key .= '_anchored' if $ANCHORED;
    $key .= '_captures' if $CAPTURES;

    return $REGEXES{$key};
}

1;

