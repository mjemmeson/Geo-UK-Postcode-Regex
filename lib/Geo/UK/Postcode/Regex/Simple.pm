package Geo::UK::Postcode::Regex::Simple;

# VERSION

# ABSTRACT: Simplified interface to Geo::UK::Postcode::Regex

use strict;
use warnings;

use Carp;

use base 'Exporter';

use Geo::UK::Postcode::Regex qw/ %REGEXES /;

our @EXPORT_OK = qw/ postcode_re extract_pc parse_pc validate_pc /;
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

our $MODE     = 'strict'; # or valid or lax
our $PARTIAL  = 0;
our $ANCHORED = 1;
our $CAPTURES = 1;

sub import {
    my $class = shift;

    my %tags = map { $_ => 1 } @_;

    $MODE
        = delete $tags{'-valid'}  ? 'valid'
        : delete $tags{'-lax'}    ? 'lax'
        : delete $tags{'-strict'} ? 'strict'
        :                           $MODE;

    $PARTIAL    #
        = delete $tags{'-partial'} ? 1
        : delete $tags{'-full'}    ? 0
        :                            $PARTIAL;
    $ANCHORED
        = delete $tags{'-unanchored'} ? 0
        : delete $tags{'-anchored'}   ? 1
        :                               $ANCHORED;
    $CAPTURES
        = delete $tags{'-nocaptures'} ? 0
        : delete $tags{'-nocaptures'} ? 1
        :                               $CAPTURES;

    local $Exporter::ExportLevel = 1;
    $class->SUPER::import( keys %tags );
}

sub postcode_re {

    croak "invalid \$MODE $MODE" if $MODE !~ m/^(?:strict|lax|valid)$/;

    my $key = $MODE;
    $key .= '_partial'  if $PARTIAL;
    $key .= '_anchored' if $ANCHORED;
    $key .= '_captures' if $CAPTURES;

    return $REGEXES{$key};
}

sub parse_pc {
    Geo::UK::Postcode::Regex->parse(
        shift,
        {   partial => $PARTIAL         ? 1 : 0,
            strict  => $MODE eq 'lax'   ? 0 : 1,
            valid   => $MODE eq 'valid' ? 1 : 0
        }
    );
}

sub extract_pc {
    Geo::UK::Postcode::Regex->extract(
        shift,
        {   strict => $MODE eq 'lax'   ? 0 : 1,
            valid  => $MODE eq 'valid' ? 1 : 0
        }
    );
}

sub validate_pc {
    my $pc = shift;

    return
          $MODE eq 'valid'  ? Geo::UK::Postcode::Regex->is_valid_pc($pc)
        : $MODE eq 'strict' ? Geo::UK::Postcode::Regex->is_strict_pc($pc)
        : $MODE eq 'lax'    ? Geo::UK::Postcode::Regex->is_lax_pc($pc)
        :                     croak "Invalid \$MODE: $MODE";
}

=head1 NAME

Geo::UK::Postcode::Regex::Simple

=head1 SYNOPSIS

    use Geo::UK::Postcode::Regex::Simple
        qw/ postcode_re parse_pc extract_pc validate_pc /;


    my $re = postcode_re;



=head1 DESCRIPTION



=cut

1;

