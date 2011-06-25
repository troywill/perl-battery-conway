package Computer::Battery;
$VERSION = 1.00;
use strict;
use vars qw( $AUTOLOAD );    # Keep 'use strict' happy
use Carp;

{

    # Encapsulated class data
    my %_attr_data =         #	DEFAULT	ACCESSIBILITY
      (
        _state              => [ '???', 'read/write' ],
        _remaining_capacity => [ '???', 'read/write' ],
        _present_voltage    => [ '???', 'read/write' ]
      );

    my $_count = 0;

    # Class methods, to operate on encapsulated class data

    # Is a specified object attribute accessible in a given mode
    sub _accessible {
        my ( $self, $attr, $mode ) = @_;
        $_attr_data{$attr}[1] =~ /$mode/;
    }

    # Classwide default value for a specified object attribute
    sub _default_for {
        my ( $self, $attr ) = @_;
        $_attr_data{$attr}[0];
    }

    # List of names of all specified object attributes
    sub _standard_keys {
        keys %_attr_data;
    }

}

# Constructor may be called as a class method
# (in which case it uses the class's default values),
# or an object method
# (in which case it gets defaults from the existing object)

sub new {
    my ( $caller, %arg ) = @_;
    my $caller_is_obj = ref($caller);
    my $class         = $caller_is_obj || $caller;
    my $self          = bless {}, $class;
    foreach my $membername ( $self->_standard_keys() ) {
        my ($argname) = ( $membername =~ /^_(.*)/ );
        if ( exists $arg{$argname} ) { $self->{$membername} = $arg{$argname} }
        elsif ($caller_is_obj) { $self->{$membername} = $caller->{$membername} }
        else { $self->{$membername} = $self->_default_for($membername) }
    }
    return $self;
}

# Destructor adjusts class count
sub DESTROY {
    $_[0]->_decr_count();
}

sub read_state {
    my $self = shift;
    open( my $state, "<", "/proc/acpi/battery/BAT0/state" )
      or warn "not able to open state file";
    while (<$state>) {
        if (/remaining/) {
            my @array              = split;
            my $remaining_capacity = $array[2];
            $self->set_remaining_capacity($remaining_capacity);
        }
        elsif (/charging state/) {
            my @array          = split;
            my $charging_state = $array[2];
            $self->set_state($charging_state);
        }
        elsif (/present rate/) {
            my @array        = split;
            my $present_rate = $array[2];

            #            $self->present_rate($present_rate);
        }
        elsif (/present voltage/) {
            my @array           = split;
            my $present_voltage = $array[2];
            $self->set_present_voltage($present_voltage);
        }
    }
    close $state;
    return;
}

sub print_state {
    my $self               = shift;
    my $state              = $self->get_state;
    my $remaining_capacity = $self->get_remaining_capacity / 1000;
    my $present_voltage    = $self->get_present_voltage / 1000;
    print "$state, $remaining_capacity A, $present_voltage V\n";
    return;
}

# Implement other get_... and set_... methods (create as necessary)

sub AUTOLOAD {
    no strict "refs";
    my ( $self, $newval ) = @_;

    # Was it a get_... method?
    if ( $AUTOLOAD =~ /.*::get(_\w+)/ && $self->_accessible( $1, 'read' ) ) {
        my $attr_name = $1;
        *{$AUTOLOAD} = sub { return $_[0]->{$attr_name} };
        return $self->{$attr_name};
    }

    # Was it a set_... method?
    if ( $AUTOLOAD =~ /.*::set(_\w+)/ && $self->_accessible( $1, 'write' ) ) {
        my $attr_name = $1;
        *{$AUTOLOAD} = sub { $_[0]->{$attr_name} = $_[1] };
        $self->{$1} = $newval;
        return;
    }

    # Must have been a mistake then...
    croak "No such method: $AUTOLOAD";
}

1;
