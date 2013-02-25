use strict;
use warnings;
package Test::Deep::Type;
# ABSTRACT: ...

use parent 'Test::Deep::Cmp';
use Exporter 'import';
use Scalar::Util 'blessed';
use Safe::Isa;

our @EXPORT = qw(is_type);

sub is_type($)
{
    my $type = shift;
    return __PACKAGE__->new($type);
}

sub init
{
    my ($self, $type) = @_;
    $self->{type} = $type;
}

sub descend
{
    my ($self, $got) = @_;
    return $self->_is_type($self->{type}, $got);
}

sub diag_message
{
    my ($self, $where) = @_;
    return "Validating $where as a " . $self->_type_name($self->{type}) . ' type';
}

# we do not define a diagnostics sub, so we get the one produced by deep_diag
# showing exactly what part of the data structure failed. This calls renderGot
# and renderVal:

sub renderGot
{
    my $self = shift;
    return $self->{error_message};
}

sub renderExp
{
    my $self = shift;
    return 'no error';
}

sub _is_type
{
    my ($self, $type, $got) = @_;

    my $error_message =
        $type->$_can('validate')
        ? $type->validate($got)
        :
            # otherwise, assume it is or quacks like a coderef
            $type->($got)
            ? undef     # validation succeeded
            : 'failed';

    return 1 if not defined $error_message;

    $self->{error_message} = $error_message;
    return;
}

sub _type_name
{
    my ($self, $type) = @_;

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
