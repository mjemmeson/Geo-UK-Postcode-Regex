# parse.t

use Test::More;

use strict;
use warnings;

use lib 't/lib';
use TestGeoUKPostcode;

use Data::Dumper;
use Clone qw/ clone /;
use Geo::UK::Postcode::Regex;

local $Data::Dumper::Sortkeys = 1;

my $pkg = 'Geo::UK::Postcode::Regex';

my @tests = (
    { 'parse'              => {} },
    { 'strict'             => { strict => 1 } },
    { 'valid'              => { valid => 1 } },
    { 'partial'            => { partial => 1 } },
    { 'strict and valid'   => { strict => 1, valid => 1 } },
    { 'strict and partial' => { strict => 1, partial => 1 } },
    { 'valid and partial'  => { valid => 1, partial => 1 } },
);

foreach (@tests) {
    my ($note,$args) = each %{$_};
    subtest( $note => sub {test_parse( $args ) });
}

sub msg {
    my ( $pc, $expected ) = @_;
    return $expected->{area}
        ? "$pc parsed as expected"
        : "$pc invalid as expected";
}

sub test_parse {
    my ( $tests, $options ) = @_;

    $options ||= {};

    foreach my $pc ( TestGeoUKPostcode->test_pcs($options) ) {

        my @raw_list = TestGeoUKPostcode->get_format_list($pc);

        foreach my $raw (@raw_list) {

            my $expected = clone $pc;

            delete $expected->{raw};
            delete $expected->{fixed_format};

            if ( $expected->{area} ) {
                $expected->{outcode} = sprintf( "%s%s%s",
                    $expected->{area}, $expected->{district},
                    $expected->{subdistrict} || '' );

                $expected->{incode} = sprintf( "%s%s",
                    $expected->{sector} || '',
                    $expected->{unit}   || '' );

                $expected->{valid_outcode} ||= 0;
                $expected->{partial}       ||= 0;
                $expected->{strict}        ||= 0;
            }

            $expected = undef    #
                if !$expected->{area}
                || ( $options->{strict} && !$expected->{strict}
                or $options->{valid} && !$expected->{valid_outcode}
                or !$options->{partial} && $expected->{partial} );

            my $parsed = $pkg->parse( $raw, $options );

            is_deeply $parsed, $expected, msg( $raw, $expected )
                or die Dumper(
                { parsed => $parsed, raw => $raw, expected => $expected } );

        }
    }
}

done_testing();

