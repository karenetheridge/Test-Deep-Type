# NAME

Test::Deep::Type - A Test::Deep plugin for validating type constraints

# VERSION

version 0.004

# SYNOPSIS

    use Test::More;
    use Test::Deep;
    use Test::Deep::Type;
    use MooseX::Types::Moose 'Str';

    cmp_deeply(
        {
            message => 'ack I am slain',
            counter => 123,
        },
        {
            message => is_type(Str),
            counter => is_type(sub { die "not an integer" unless int($_[0]) eq $_[0] }),
        },
        'message is a plain string, counter is a number',
    );

# DESCRIPTION

`Test::Deep::Type` provides the sub `is_type` to indicate that the data
being tested must validate against the passed type. This is an actual type
_object_, not a string name -- for example something provided via
[MooseX::Types](http://search.cpan.org/perldoc?MooseX::Types), or a plain old coderef that returns a bool (such as what
might be used in a [Moo](http://search.cpan.org/perldoc?Moo) type constraint).

# FUNCTIONS

- `is_type`

    Exported by default; to be used within a [Test::Deep](http://search.cpan.org/perldoc?Test::Deep) comparison function
    such as [cmp\_deeply](http://search.cpan.org/perldoc?Test::Deep#COMPARISON FUNCTIONS).
    As this module aims to be a solution for many popular
    type systems, we attempt to use the type in multiple ways:

    - [MooseX::Types](http://search.cpan.org/perldoc?MooseX::Types)/[Moose::Meta::TypeConstraint](http://search.cpan.org/perldoc?Moose::Meta::TypeConstraint)\-style types:

        If the `validate` method exists, it is invoked on the type object with the
        data as its parameter (which should return `undef` on success, and the error
        message on failure).

    - coderef/[Moo](http://search.cpan.org/perldoc?Moo)\-style types:

        If the type appears to be or act like a coderef (either a coderef, blessed or
        unblessed, or possesses a coderef overload) the type is invoked as a sub, with
        the data as its parameter. Its return value is treated as a boolean; if it
        also dies with a message describing the failure, this message is used in the
        failure diagnostics.

# CAVEATS

Regular strings describing a type under a particular system
(e.g. [Moose](http://search.cpan.org/perldoc?Moose), [Params::Validate](http://search.cpan.org/perldoc?Params::Validate)) are not currently supported.

# SUPPORT

Bugs may be submitted through [https://rt.cpan.org/Public/Dist/Display.html?Name=Test-Deep-Type](https://rt.cpan.org/Public/Dist/Display.html?Name=Test-Deep-Type).
I am also usually active on irc, as 'ether' at [irc://irc.perl.org](irc://irc.perl.org).

# SEE ALSO

[Test::Deep](http://search.cpan.org/perldoc?Test::Deep)

[Test::TypeConstraints](http://search.cpan.org/perldoc?Test::TypeConstraints)

[Test::Type](http://search.cpan.org/perldoc?Test::Type)

[MooseX::Types](http://search.cpan.org/perldoc?MooseX::Types)

[Moose::Meta::TypeConstraint](http://search.cpan.org/perldoc?Moose::Meta::TypeConstraint)

[Moo](http://search.cpan.org/perldoc?Moo)

[Type::Tiny](http://search.cpan.org/perldoc?Type::Tiny)

# AUTHOR

Karen Etheridge <ether@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Karen Etheridge.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
