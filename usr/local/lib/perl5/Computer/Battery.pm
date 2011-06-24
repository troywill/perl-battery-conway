package Computer::Battery;
use Moose;
has 'remaining_capacity' => (isa => 'Int', is => 'rw', default => 0);
has 'present' => (isa => 'Str', is => 'rw', default => "no");
has 'charging_state' => (isa => 'Str', is => 'rw', default => "charged");

sub BUILD {
    my $self = shift;
    $self->set_state;
}

sub get_capacity {
    my $self = shift;
    return $self->remaining_capacity;
}

sub print_state {
    my $self = shift;
    print $self->charging_state(), "\n";
    print $self->remaining_capacity(), "\n";
}

sub set_state {
    my $self = shift;
    open( my $state, "<", "/proc/acpi/battery/BAT0/state" ) or warn "not able to open state file";
    while (<$state>) {
	if ( /remaining/ ) {
	    my @array = split;
	    my $remaining_capacity = $array[2];
	    $self->remaining_capacity($remaining_capacity);
	} elsif ( /charging state/ ) {
	    my @array = split;
	    my $charging_state = $array[2];
	    $self->charging_state($charging_state);
	}
    }
    close $state;
}

1;

__END__
has 'present' => (isa => , is => 'rw', default => );
has 'capacity' => (isa => , is => 'rw', default => );
has 'charging' => (isa => , is => 'rw', default => );
has 'present' => (isa => , is => 'rw', default => );
has 'remaining' => (isa => , is => 'rw', default => );
has 'present' => (isa => , is => 'rw', default => );
