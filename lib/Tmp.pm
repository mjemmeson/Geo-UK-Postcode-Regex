package Tmp;

require Tie::Hash;

our @ISA = qw/ Tie::StdHash /;

sub TIEHASH {
    my $storage = bless {}, shift;
    return $storage;
}

sub FETCH {
    my ($this,$key) = @_;

    $this->{$key} //= 10;

    return $this->{$key};
}


