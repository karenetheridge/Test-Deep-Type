use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More tests => 16;
use Test::NoWarnings 1.04 ':early';
use Test::Fatal;

use Test::Deep;
use Test::Deep::Type;

# FIXME: we should be able to pass an import arg to Test::Requires
BEGIN {
    use Test::Requires 'MooseX::Types::Moose';
    MooseX::Types::Moose->import('Str');
}

check_tests(
    sub {
        cmp_deeply(
            { message => 'ack I am slain' },
            { message => is_type(Str) },
            'message is a string',
        );
        cmp_deeply(
            { message => { foo => 1 } },
            { message => is_type(Str) },
            'message is a string',
        );
    },
    [
        {
            actual_ok => 1,
            ok => 1,
            diag => '',
            name => 'message is a string',
            type => '',
        },
        {
            actual_ok => 0,
            ok => 0,
            name => 'message is a string',
            type => '',
            diag => <<EOM,
Validating \$data->{"message"} as a Str type
   got : Validation failed for 'Str' with value { foo: 1 }
expect : no error
EOM
        },
    ],
    'success and failure with a MooseX::Types type',
);

