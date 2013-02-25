use strict;
use warnings;
package Test::Deep::Type;
# ABSTRACT: ...

use Exporter 'import';
use Test::Deep '!blessed';
use Scalar::Util 'blessed';
use Safe::Isa;

our @EXPORT = qw(is_type);

sub is_type
{
    my $type = shift;

    return code(sub {
        my $got = shift;

        my $error_message =
            $type->$_can('validate')
            ? $type->validate($got)
            :
                # otherwise, assume it is or quacks like a coderef
                $type->($got)
                ? undef     # validation succeeded
                : _type_name($type) . ' validation did not succeed';

        return 1 if not $error_message;
        return 0, $error_message;
    });
}

sub _type_name
{
    my $type = shift;

    # use $type->name if we can
    my $name_sub = $type->$_can('name');
    return $name_sub->() if $name_sub;

    # ...or its package name, if it has one
    my $class = blessed($type);
    return $class if defined $class;

    # plain old subref perhaps?
    return 'unknown type';
}

1;
__END__

=pod

=head1 SYNOPSIS

...

=head1 METHODS

=over

=item * C<foo>

=back

...

=head1 SUPPORT

Bugs may be submitted through L<https://rt.cpan.org/Public/Dist/Display.html?Name={{ $DIST }} >.
I am also usually active on irc, as 'ether' at L<irc://irc.perl.org>.

=head1 ACKNOWLEDGEMENTS

...

=head1 SEE ALSO

...

=cut
