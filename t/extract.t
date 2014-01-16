use Test::More;

use strict;
use warnings;

use Geo::UK::Postcode::Regex;

use lib 't/lib';
use TestGeoUKPostcode;

my $pkg = 'Geo::UK::Postcode::Regex';

my @tests = (
    { extract => { partial => 0 } },                #
    { strict  => { partial => 0, strict => 1 } },
    { valid   => { partial => 0, valid => 1 } },
);

foreach my $test (@tests) {
    my ( $note, $args ) = each %{$test};
    subtest( $note => sub { test_extract($args) } );
}

sub test_extract {
    my ($options) = @_;

    $options ||= {};

    my @pcs = grep { $_->{area} } TestGeoUKPostcode->test_pcs($options);

    my @list = map { TestGeoUKPostcode->get_format_list($_) } @pcs;

    my $string = join( ' abc ', @list );

    my @extracted = $pkg->extract( $string, $options );
    ok scalar(@extracted), "extracted ok";

    is_deeply \@extracted, \@list, "extracted postcodes match list";
}

done_testing();

