# simple.t

use Test::More;

use strict;
use warnings;

use Geo::UK::Postcode::Regex::Simple '-lax', ':all';

ok my $re = postcode_re, "got postcode regex";
ok 'AB10 1AA' =~ $re, "regex ok";
ok 'XX1 1AA' =~ $re,  "lax regex ok";

{
    local $Geo::UK::Postcode::Regex::Simple::MODE = 'strict';
    ok $re = postcode_re, "got strict postcode regex";
    ok 'AB10 1AA' =~ $re, "strict regex ok";
    ok 'XX10 1AA' !~ $re, "strict regex ok";
}

done_testing();

