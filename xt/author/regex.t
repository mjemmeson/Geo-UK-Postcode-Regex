use Test::More;

use strict;
use warnings;

use Geo::UK::Postcode::Regex;
use Geo::UK::Postcode::CodePointOpen;

my $path = $ENV{CODE_POINT_OPEN_DATA}
    or plan skip_all => "CODE_POINT_OPEN_DATA not set";

my $lax_re    = Geo::UK::Postcode::Regex->regex;
my $strict_re = Geo::UK::Postcode::Regex->strict_regex;
my $valid_re  = Geo::UK::Postcode::Regex->valid_regex;

my $code_point_open = Geo::UK::Postcode::CodePointOpen->new( path => $path );

my $iterator = $code_point_open->read_iterator();
while ( my $pc = $iterator->() ) {

    note $pc->{Postcode};

    ok( my $parsed = Geo::UK::Postcode::Regex->parse( $pc->{Postcode} ),
        "parsed" );
    ok $parsed->{strict}, "strict";
    ok $parsed->{valid},  "valid";

    ok $pc->{Postcode} =~ $lax_re,    "match lax_re";
    ok $pc->{Postcode} =~ $strict_re, "match strict_re";
    ok $pc->{Postcode} =~ $valid_re,  "match valid_re";

}

done_testing();

