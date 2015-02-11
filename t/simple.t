use Test::More;
use Test::Exception;

use strict;
use warnings;

use lib 't/lib';
use TestGeoUKPostcode;

use Geo::UK::Postcode::Regex::Simple ':all';

{
    local $Geo::UK::Postcode::Regex::Simple::MODE = 'foo';
    dies_ok {postcode_re} "dies with invalid mode";
    dies_ok {validate_pc} "dies with invalid mode";
}

my @test_pcs = TestGeoUKPostcode->test_pcs();
my @test_pcs_partial = TestGeoUKPostcode->test_pcs( { partial => 1 } );

foreach my $mode (qw( valid strict lax )) {

    foreach my $length (qw( partial full )) {

        foreach my $case (qw( case-insensitive case-sensitive )) {

            subtest "$mode-$length-$case" => sub {

                foreach my $captures (qw( nocaptures captures )) {

                    subtest "postcode_re $captures" => sub {

                        Geo::UK::Postcode::Regex::Simple->import(    #
                            "-$mode",
                            "-$case",
                            "-$length",
                            "-$captures"
                        );

                        ok my $re = postcode_re, "got postcode regex";

                        foreach my $pc ( @test_pcs, @test_pcs_partial ) {

                            subtest $pc->{raw} => sub {
                                test_postcode_against_regex(
                                    $pc => {
                                        mode     => $mode,
                                        length   => $length,
                                        case     => $case,
                                        captures => $captures,
                                        re       => $re,
                                    }
                                );
                            };
                        }
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

            if ( $test->{captures} eq 'captures' ) {
                ok my @matches = $str =~ $re,
                    "$str matches $mode, $length, $case";

                test_postcode_captures( $pc, $test, @matches );
            } else {
                ok $str=~ $re, "$str matches $mode, $length, $case";
            }

        } else {
            ok $str !~ $re, "$str doesn't match $mode, $length, $case";
        }
    }

    my @strings_lc = TestGeoUKPostcode->get_lc_format_list($pc);

    $match = 0 if $case eq 'case-sensitive';

    foreach my $str (@strings_lc) {
        if ($match) {
            if ( $test->{captures} eq 'captures' ) {
                ok my @matches = $str =~ $re,
                    "$str matches $mode, $length, $case";
                test_postcode_captures( $pc, $test, @matches );
            } else {
                ok $str=~ $re, "$str matches $mode, $length, $case";
            }
        } else {
            ok $str !~ $re, "$str doesn't match $mode, $length, $case";
        }
    }
}

sub test_postcode_captures {
    my ( $pc, $test, @matches ) = @_;

    my ( $outcode, $area, $district, $sector, $unit );

    if ( $test->{case} eq 'case-insensitive' ) {
        $outcode  = uc $outcode  if $outcode;
        $area     = uc $area     if $area;
        $district = uc $district if $district;
        $sector   = uc $sector   if $sector;
        $unit     = uc $unit     if $unit;
    }

    if ( $test->{mode} eq 'valid' ) {
        ( $outcode, $sector, $unit ) = @matches;

        if ( $test->{case} eq 'case-insensitive' ) {
            $outcode = uc $outcode if $outcode;
            $sector  = uc $sector  if $sector;
            $unit    = uc $unit    if $unit;
        }

        if ( $pc->{outcode} ) {
            is $outcode, $pc->{outcode}, "Outcode matched ok";
        } else {
            ok !$outcode, "Outcode not matched";
        }

    } else {
        ( $area, $district, $sector, $unit ) = @matches;

        if ( $test->{case} eq 'case-insensitive' ) {
            $area     = uc $area     if $area;
            $district = uc $district if $district;
            $sector   = uc $sector   if $sector;
            $unit     = uc $unit     if $unit;
        }

        if ( $pc->{area} ) {
            is $area, $pc->{area}, "Area matched ok";
        } else {
            ok !$area, "Area not matched";
        }

        if ( $pc->{subdistrict} ) {
            is $district, $pc->{district} . $pc->{subdistrict},
                "District (including subdistrict) matched ok";
        } elsif ( $pc->{district} ) {
            is $district, $pc->{district}, "District matched ok";
        } else {
            ok !$district, "District not matched";
        }
    }

    if ( $pc->{sector} ) {
        is $sector, $pc->{sector}, "Sector matched ok";
    } else {
        ok !$sector, "Sector not matched";
    }

    if ( $pc->{unit} ) {
        is $unit, $pc->{unit}, "Unit matched ok";
    } else {
        ok !$unit, "Unit not matched";
    }

}

