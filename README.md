# NAME

Geo::UK::Postcode::Regex - regular expressions for handling British postcodes

# SYNOPSIS

See [Geo::UK::Postcode::Regex::Simple](https://metacpan.org/pod/Geo::UK::Postcode::Regex::Simple) for an alternative interface.

    use Geo::UK::Postcode::Regex;

    ## REGULAR EXPRESSIONS

    my $lax_re    = Geo::UK::Postcode::Regex->regex;
    my $strict_re = Geo::UK::Postcode::Regex->strict_regex;
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

    use Geo::UK::Postcode::Regex qw( is_valid_pc is_strict_pc is_lax_pc );

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
    #     valid            => 1,
    #     strict           => 1,
    #     partial          => 0,
    #     non_geographical => 0,
    #     bfpo             => 0,
    # }

    # strict parsing (only valid characters):
    ...->parse( $pc, { strict => 1 } )

    # valid outcodes only
    ...->parse( $pc, { valid => 1 } )

    # match partial postcodes, e.g. 'WC1H', 'WC1H 9' - see below
    ...->parse( $pc, { partial => 1 } )


    ## PARSING PARTIAL POSTCODES

    # outcode (district) only
    my $parsed = Geo::UK::Postcode::Regex->parse( "AB10", { partial => 1 } );

    # returns:
    # {   area             => 'AB',
    #     district         => '10',
    #     subdistrict      => undef,
    #     sector           => undef,
    #     unit             => undef,
    #     outcode          => 'AB10',
    #     incode           => undef,
    #     valid            => 1,
    #     strict           => 1,
    #     partial          => 1,
    #     non_geographical => 0,
    #     bfpo             => 0,
    # }

    # sector only
    my $parsed = Geo::UK::Postcode::Regex->parse( "AB10 1", { partial => 1 } );

    # returns:
    # {   area             => 'AB',
    #     district         => '10',
    #     subdistrict      => undef,
    #     sector           => 1,
    #     unit             => undef,
    #     outcode          => 'AB10',
    #     incode           => '1',
    #     valid            => 1,
    #     strict           => 1,
    #     partial          => 1,
    #     non_geographical => 0,
    #     bfpo             => 0,
    # }


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

Parsing UK postcodes with regular expressions (aka Regexp). This package has
been separated from [Geo::UK::Postcode](https://metacpan.org/pod/Geo::UK::Postcode) so it can be installed and used with
fewer dependencies.

Can handle partial postcodes (just the outcode or sector) and can test
against valid characters and currently valid outcodes.

Also can determine the posttown(s) from a postcode.

Districts and post town information taken from:
[https://en.wikipedia.org/wiki/Postcode\_districts](https://en.wikipedia.org/wiki/Postcode_districts)

# IMPORTANT CHANGES FOR VERSION 0.014

Please note that various bugfixes have changed the following:

- Unanchored regular expressions no longer match valid postcodes within invalid
ones.
- Unanchored regular expressions in partial mode now can match a valid or strict
outcode with an invalid incode.

Please get in touch if you have any questions.

See [Geo::UK::Postcode::Regex::Simple](https://metacpan.org/pod/Geo::UK::Postcode::Regex::Simple) for other changes affecting the Simple
interface.

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

Returns hashref of the constituent parts - see SYNOPSIS. Missing parts will be
set as undefined.

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

- [Geo::UK::Postcode](https://metacpan.org/pod/Geo::UK::Postcode) - companion package, provides Postcode objects
- [Geo::Address::Mail::UK](https://metacpan.org/pod/Geo::Address::Mail::UK)
- [Geo::Postcode](https://metacpan.org/pod/Geo::Postcode)
- [Data::Validation::Constraints::Postcode](https://metacpan.org/pod/Data::Validation::Constraints::Postcode)
- [CGI::Untaint::uk\_postcode](https://metacpan.org/pod/CGI::Untaint::uk_postcode)
- [Form::Validator::UKPostcode](https://metacpan.org/pod/Form::Validator::UKPostcode)

# SUPPORT

## Bugs / Feature Requests

Please report any bugs or feature requests through the issue tracker
at [https://github.com/mjemmeson/geo-uk-postcode-regex/issues](https://github.com/mjemmeson/geo-uk-postcode-regex/issues).
You will be notified automatically of any progress on your issue.

## Source Code

This is open source software.  The code repository is available for
public review and contribution under the terms of the license.

[https://github.com/mjemmeson/geo-uk-postcode-regex](https://github.com/mjemmeson/geo-uk-postcode-regex)

    git clone git://github.com/mjemmeson/geo-uk-postcode-regex.git

# AUTHOR

Michael Jemmeson <mjemmeson@cpan.org>

# CONTRIBUTORS

- Tom Bloor `TBSLIVER`

# COPYRIGHT

Copyright 2015-2017 Michael Jemmeson

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
