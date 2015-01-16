use Test::More;

use strict;
use warnings;

use lib 't/lib';
use TestGeoUKPostcode;

use Geo::UK::Postcode::Regex::Simple ':all';

local $Geo::UK::Postcode::Regex::Simple::MODE = 'strict';

my @test_pcs = TestGeoUKPostcode->test_pcs();
my @test_pcs_partial = TestGeoUKPostcode->test_pcs( { partial => 1 } );

foreach my $mode (qw( valid strict lax )) {

    foreach my $length (qw( partial full )) {

        foreach my $case (qw( case-insensitive case-sensitive )) {

            subtest "$mode-$length-$case" => sub {

                Geo::UK::Postcode::Regex::Simple->import(    #
                    "-$mode",
                    "-$case",
                    "-$length"
                );

                ok my $re = postcode_re, "got postcode regex";

                foreach my $pc ( @test_pcs, @test_pcs_partial ) {

                    subtest $pc->{raw} => sub {
                        test_postcode_against_regex(
                            $pc => {
                                mode   => $mode,
                                length => $length,
                                case   => $case,
                                re     => $re,
                            }
                        );
                    };
                }
            };
        }
    }
}

done_testing();

sub test_postcode_against_regex {
    my ( $pc, $test ) = @_;

    my ( $mode, $length, $case, $re ) = @{$test}{qw( mode length case re )};

    my @strings = TestGeoUKPostcode->get_format_list($pc);

    my $match = 1;
    $match = 0 unless $pc->{$mode};
    $match = 0 if $pc->{partial} && $length eq 'full';

    foreach my $str (@strings) {
        if ($match) {
            ok $str =~ $re, "$str matches $mode, $length, $case";
        } else {
            ok $str !~ $re, "$str doesn't match $mode, $length, $case";
        }
    }

    my @strings_lc = TestGeoUKPostcode->get_lc_format_list($pc);

    $match = 0 if $case eq 'case-sensitive';

    foreach my $str (@strings_lc) {
        if ($match) {
            ok $str =~ $re, "$str matches $mode, $length, $case";
        } else {
            ok $str !~ $re, "$str doesn't match $mode, $length, $case";
        }
    }
}

