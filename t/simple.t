use Test::More;
use Test::Exception;

use strict;
use warnings;

use Geo::UK::Postcode::Regex::Simple ':all';

# TODO make this more thorough, like the simple-import-args.t tests
# and loop through all combinations of options

{
    local $Geo::UK::Postcode::Regex::Simple::MODE = 'foo';
    dies_ok {postcode_re} "dies with invalid mode";
    dies_ok {validate_pc} "dies with invalid mode";
}

subtest(
    postcode_re => sub {
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
            ok 'XX10 1AA' !~ $re, "valid regex ok - fail";
            ok 'CW13 1AA' !~ $re, "valid regex ok - fail";

            ok 'AB10 1AA' =~ $re, "valid regex ok - success";
            ok my @matches = 'AB10 1AA' =~ $re, "got captures";
            is_deeply \@matches, [ 'AB10', '1', 'AA' ], "captures ok";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::ANCHORED = 0;
            ok $re = postcode_re, "got unanchored postcode regex";
            ok 'blah AB10 1AA blah' =~ $re, "unanchored regex ok";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::ANCHORED = 1;
            ok $re = postcode_re, "got anchored postcode regex";
            ok 'blah AB10 1AA blah' !~ $re, "anchored regex ok";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::CAPTURES = 0;
            ok $re = postcode_re, "got postcode regex with no captures";
            ok my @matches = 'AB10 1AA' =~ $re, "regex ok with no captures";
            is_deeply \@matches, [1], "no matches, only true value";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::CASE_INSENSITIVE = 1;
            ok $re = postcode_re, "got case-insensitive postcode regex";
            ok 'ab10 1aa' =~ $re, "regex ok with lower case postcode";
            ok 'AB10 1AA' =~ $re, "regex ok with upper case postcode";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::PARTIAL = 1;
            ok $re = postcode_re, "got partial postcode regex";

            ok my @matches = 'AB10 1AA' =~ $re, "regex ok with full postcode";
            is_deeply \@matches, [ 'AB', '10', '1', 'AA' ], "captures ok";

            ok @matches = 'AB10' =~ $re, "regex ok with partial postcode";
            is_deeply \@matches, [ 'AB', '10', undef, undef ], "captures ok";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::PARTIAL = 1;
            local $Geo::UK::Postcode::Regex::Simple::MODE    = 'valid';

            ok $re = postcode_re, "got partial valid postcode regex";

            ok my @matches = 'AB10 1AA' =~ $re, "regex ok with full postcode";
            is_deeply \@matches, [ 'AB10', '1', 'AA' ], "captures ok";

            ok @matches = 'AB10' =~ $re, "regex ok with partial postcode";
            is_deeply \@matches, [ 'AB10', undef, undef ], "captures ok";

            ok @matches = 'E14' =~ $re, "regex ok with partial postcode";
            is_deeply \@matches, [ 'E14', undef, undef ], "captures ok";
        }
    }
);

subtest(
    parse_pc => sub {
        {
            ok my $parsed = parse_pc("AB10 1AA"), "parse_pc with defaults";
            is $parsed->{unit}, 'AA', "parsed ok";
            ok !parse_pc("XX10 1AA"), "parse_pc with defaults - strict mode";
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::MODE = 'lax';
            ok my $parsed = parse_pc("AB10 1BB"), "parse_pc, lax mode";
            is $parsed->{unit}, 'BB', "parsed ok";
            ok $parsed = parse_pc("XX10 1XX"), "parse_pc, lax mode";
            is $parsed->{unit}, 'XX', "parsed ok";
        }

    }
);

subtest(
    extract => sub {

        {
            note "with defaults";
            ok my @extracted
                = extract_pc "my postcodes are AB10 1AA and wc1A 9zz.",
                "extract_pc";
            is_deeply \@extracted, ['AB10 1AA'];
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::CASE_INSENSITIVE = 1;
            note "case-insensitive";
            ok my @extracted
                = extract_pc "my postcodes are AB10 1AA and wc1A 9zz.",
                "extract_pc";
            is_deeply \@extracted, [ 'AB10 1AA', 'WC1A 9ZZ' ];
        }
    }
);

subtest(
    validate_pc => sub {
        note "with defaults";
        ok validate_pc("AB10 1AA");
        ok !validate_pc("XX10 1AA");
        ok !validate_pc("ab10 1aa");

        {
            local $Geo::UK::Postcode::Regex::Simple::CASE_INSENSITIVE = 1;
            note "case-insensitive";
            ok validate_pc("AB10 1AA");
            ok !validate_pc("XX10 1AA");
            ok validate_pc("ab10 1aa");
        }

        {
            local $Geo::UK::Postcode::Regex::Simple::ANCHORED = 0;
            note "unanchored";
            ok validate_pc(" this string contains AB10 1AA a postcode");
            ok !validate_pc(" this string contains XX10 1AA a postcode");
            ok !validate_pc(" this string contains ab10 1aa a postcode");
        }

    }
);

done_testing();

