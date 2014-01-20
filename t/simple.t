# simple.t

use Test::More;

use strict;
use warnings;

use Geo::UK::Postcode::Regex::Simple qw/ postcode_re /;

ok my $re = postcode_re, "got postcode regex";
ok 'AB10 1AA' =~ $re, "regex ok";

{
    local $Geo::UK::Postcode::Regex::Simple::MODE = 'lax';
    ok $re = postcode_re, "got lax postcode regex";
    ok 'XX10 1AA' =~ $re, "lax regex ok";
}

{
    local $Geo::UK::Postcode::Regex::Simple::MODE = 'valid';
    ok $re = postcode_re, "got valid postcode regex";
    ok 'XX10 1AA' !~ $re, "valid regex ok";
    ok 'AB1 1AA' !~ $re,  "valid regex ok";
    ok 'AB10 1AA' =~ $re, "valid regex ok";
}

{
    local $Geo::UK::Postcode::Regex::Simple::ANCHORED = 0;
    ok $re = postcode_re, "got unanchored postcode regex";
    ok 'blah AB10 1AA blah' =~ $re, "unanchored regex ok";
}

{
    local $Geo::UK::Postcode::Regex::Simple::CAPTURES = 0;
    ok $re = postcode_re, "got postcode regex with no captures";
    ok my @matches = 'AB10 1AA' =~ $re, "regex ok with no captures";
    is_deeply \@matches, [1], "no matches, only true value";
}

done_testing();

