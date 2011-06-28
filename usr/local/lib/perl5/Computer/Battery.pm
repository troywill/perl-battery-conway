package Computer::Battery;
$VERSION = 4.00;
use Class::MethodMaker
    new_with_init => 'new',
    new_hash_init => '_init_args',
    get_set => [qw(remaining_capacity present_rate present charging_state)];

