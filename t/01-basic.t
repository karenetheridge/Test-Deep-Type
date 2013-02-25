use strict;
use warnings FATAL => 'all';

use Test::Tester 0.108;
use Test::More tests => 33;
use Test::NoWarnings 1.04 ':early';
use Test::Deep;
use Test::Deep::Type;

# this should not be needed...
# Test::Deep::builder(Test::Tester::capture());

# the first type is an object that implements 'validate', just like
# MooseX::Types and Moose::Meta::TypeConstraint do
{
    package TypeHi;
    sub validate
    {
        my ($self, $val) = @_;
        return "undef is not a 'hi'" if not defined $val;
        return undef if $val eq 'hi';   # validated: no error
        "'$val' is not a 'hi'";
    }
}

sub TypeHi { bless {}, 'TypeHi' }

is(TypeHi->validate('hi'), undef, 'validation succeeds (no error)');
is(TypeHi->validate('hello'), "'hello' is not a 'hi'", 'validation fails with error');

# the next type is an object that quacks like a coderef, returning a simple
# boolean "did this validate"
sub TypeHiLite
{
    bless sub {
        my $val = shift;
        return if not defined $val;
        return 1 if $val eq 'hi';   # validated: no error
        return;
    }, 'TypeHiLite';
}

ok(TypeHiLite->('hi'), 'validation succeeds (no error)');
ok(!TypeHiLite->('hello'), 'validation fails with a simple bool');


check_tests(
    sub {
        cmp_deeply({ greeting => 'hi' }, { greeting => is_type(TypeHi) }, 'hi validates as a TypeHi');
        cmp_deeply({ greeting => 'hi' }, { greeting => is_type(TypeHiLite) }, 'hi validates as a TypeHiLite');
    },
    [ map { +{
        actual_ok => 1,
        ok => 1,
        diag => '',
        name => "hi validates as a $_",
        type => '',
    } } qw(TypeHi TypeHiLite) ],
    'validation successful',
);


my ($premature, @results) = run_tests(
    sub {
        cmp_deeply({ greeting => 'hello' }, { greeting => is_type(TypeHi) }, 'hello validates as a TypeHi?');
        cmp_deeply({ greeting => 'hello' }, { greeting => is_type(TypeHiLite) }, 'hello validates as a TypeHiLite?');
    },
);
Test::Tester::cmp_results(
    \@results,
    [ map { +{
        actual_ok => 0,
        ok => 0,
        name => "hello validates as a $_?",
        type => '',
    } } qw(TypeHi TypeHiLite) ],
    'validation fails',
);

# for now, we care just that the diagnostic is in there somewhere
like($results[0]->{diag}, qr/'hello' is not a 'hi'/, 'error message is included');
like($results[1]->{diag}, qr/TypeHiLite validation did not succeed/);

