# NAME

Geo::UK::Postcode::Regex

# SYNOPSIS

See [Geo::UK::Postcode::Regex::Simple](https://metacpan.org/pod/Geo::UK::Postcode::Regex::Simple) for an alternative interface.

    use Geo::UK::Postcode::Regex;

    ## REGULAR EXPRESSIONS

    my $lax_re    = Geo::UK::Postcode::Regex->regex;
    my $strict_re = Geo::UK::Postcode::Regex->regex_strict;
    my $valid_re  = Geo::UK::Postcode::Regex->valid_regex;

    # matching only
    if ( $foo =~ $lax_re )    {...}
    if ( $foo =~ $strict_re ) {...}
    if ( $foo =~ $valid_re )  {...}

    # matching and using components - see also parse()
    if ( $foo =~ $lax_re ) {
        my ( $area, $district, $sector, $unit ) = ( $1, $2, $3, $4 );
        my $subdistrict = $district =~ s/([A-Z])$// ? $1 : undef;
        ...
    }
    if ( $foo =~ $strict_re ) {
        my ( $area, $district, $sector, $unit ) = ( $1, $2, $3, $4 );
        my $subdistrict = $district =~ s/([A-Z])$// ? $1 : undef;
        ...
    }
    if ( $foo =~ $valid_re ) {
        my ( $outcode, $sector, $unit ) = ( $1, $2, $3 );
        ...
    }



    ## VALIDATION METHODS
    use Geo::UK::Postcode::Regex qw/ is_valid_pc is_strict_pc is_lax_pc /;

    if (is_valid_pc("GE0 1UK")) {
        ...
    }
    if (is_strict_pc("GE0 1UK")) {
        ...
    }
    if (is_lax_pc("GE0 1UK")) {
        ...
    }



    ## PARSING
    my $parsed = Geo::UK::Postcode::Regex->parse("WC1H 9EB");

    # returns:
    # {   area             => 'WC',
    #     district         => '1',
    #     subdistrict      => 'H',
    #     sector           => '9',
    #     unit             => 'EB',
    #     outcode          => 'WC1H',
    #     incode           => '9EB',
    #     valid_outcode    => 1 | 0,
    #     strict           => 1 | 0,
    #     partial          => 1 | 0,
    #     non_geographical => 1 | 0,
    #     bfpo             => 1 | 0,
    # }

    # strict parsing (only valid characters):
    ...->parse( $pc, { strict => 1 } )

    # valid outcodes only
    ...->parse( $pc, { valid => 1 } )

    # match partial postcodes, e.g. 'WC1H', 'WC1H 9'
    ...->parse( $pc, { partial => 1 } )



    ## EXTRACT OUTCODE FROM POSTCODE
    my $outcode = Geo::UK::Postcode::Regex->outcode("AB101AA"); # returns 'AB10'

    my $outcode = Geo::UK::Postcode::Regex->outcode( $postcode, { valid => 1 } )
        or die "Invalid postcode";



    ## EXTRACT POSTCODES FROM TEXT
    # \%options as per parse, excluding partial
    my @extracted = Geo::UK::Postcode::Regex->extract( $text, \%options );



    ## POSTTOWNS
    my @posttowns = Geo::UK::Postcode::Regex->outcode_to_posttowns($outcode);



    ## OUTCODES
    my @outcodes = Geo::UK::Postcode::Regex->posttown_to_outcodes($posttown);



# DESCRIPTION

Parsing UK postcodes with regular expressions. This package has been
separated from [Geo::UK::Postcode](https://metacpan.org/pod/Geo::UK::Postcode) so it can be installed and used with fewer
dependencies.

Can handle partial postcodes (just the outcode or sector) and can test
against valid characters and currently valid outcodes.

Also can determine the posttown(s) from a postcode.

Districts and post town information taken from:
[https://en.wikipedia.org/wiki/Postcode_districts](https://en.wikipedia.org/wiki/Postcode_districts)

# NOTES AND LIMITATIONS

When parsing a partial postcode, whitespace may be required to separate the
outcode from the sector.

For example the sector 'B1 1' cannot be distinguished from the district 'B11'
without whitespace. This is not a problem when parsing full postcodes.

# VALIDATION METHODS

The following methods are for validating postcodes to various degrees.

[Geo::UK::Postcode::Regex::Simple](https://metacpan.org/pod/Geo::UK::Postcode::Regex::Simple) may provide a more convenient way of using
and customising these.

## regex, strict\_regex, valid\_regex

Return regular expressions to parse postcodes and capture the constituent
parts: area, district, sector and unit (or outcode, sector and unit in the
case of `valid_regex`).

`strict_regex` checks that the postcode only contains valid characters
according to the postcode specifications.

`valid_regex` checks that the outcode currently exists.

## regex\_partial, strict\_regex\_partial, valid\_regex\_partial

As above, but matches on partial postcodes of just the outcode
or sector

## is\_valid\_pc, is\_strict\_pc, is\_lax\_pc

    if (is_valid_pc( "AB1 2CD" ) ) { ... }

Alternative way to access the regexes.

# PARSING METHODS

The following methods are for parsing postcodes or strings containing postcodes.

## PARSING\_OPTIONS

The parsing methods can take the following options, passed via a hashref:

- strict

    Postcodes must not contain invalid characters according to the postcode
    specification. For example a 'Q' may not appear as the first character.

- valid

    Postcodes must contain an outcode (area + district) that currently exists, in
    addition to conforming to the `strict` definition.

    Returns false if string is not a currently existing outcode.

- partial

    Allows partial postcodes to be matched. In practice this means either an outcode
    ( area and district ) or an outcode together with the sector.

## extract

    my @extracted = Geo::UK::Postcode::Regex->extract( $string, \%options );

Returns a list of full postcodes extracted from a string.

## parse

    my $parsed = Geo::UK::Postcode::Regex->parse( $pc, \%options );

Returns hashref of the constituent parts.

## outcode

    my $outcode = Geo::UK::Postcode::Regex->outcode( $pc, \%options );

Extract the outcode (area and district) from a postcode string. Will work on
full or partial postcodes.

# LOOKUP METHODS

## outcode\_to\_posttowns

    my ( $posttown1, $posttown2, ... )
        = Geo::UK::Postcode::Regex->outcode_to_posttowns($outcode);

Returns posttown(s) for supplied outcode.

Note - most outcodes will only have one posttown, but some are shared between
two posttowns.

## posttown\_to\_outcodes

    my @outcodes = Geo::UK::Postcode::Regex->posttown_to_outcodes($posttown);

Returns the outcodes covered by a posttown. Note some outcodes are shared
between posttowns.

## outcodes\_lookup

    my %outcodes = %{ Geo::UK::Postcode::Regex->outcodes_lookup };
    print "valid outcode" if $outcodes{$outcode};
    my @posttowns = @{ $outcodes{$outcode} };

Hashref of outcodes to posttown(s);

## posttowns\_lookup

    my %posttowns = %{ Geo::UK::Postcode::Regex->posttowns_lookup };
    print "valid posttown" if $posttowns{$posttown};
    my @outcodes = @{ $[posttowns{$posttown} };

Hashref of posttown to outcode(s);

# SEE ALSO

- [Geo::UK::Postcode](https://metacpan.org/pod/Geo::UK::Postcode)
- [Geo::Address::Mail::UK](https://metacpan.org/pod/Geo::Address::Mail::UK)
- [Geo::Postcode](https://metacpan.org/pod/Geo::Postcode)
- [Data::Validation::Constraints::Postcode](https://metacpan.org/pod/Data::Validation::Constraints::Postcode)
- [CGI::Untaint::uk_postcode](https://metacpan.org/pod/CGI::Untaint::uk_postcode)
- [Form::Validator::UKPostcode](https://metacpan.org/pod/Form::Validator::UKPostcode)

# AUTHOR

Michael Jemmeson <mjemmeson@cpan.org>

# COPYRIGHT

Copyright 2014- Michael Jemmeson

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
