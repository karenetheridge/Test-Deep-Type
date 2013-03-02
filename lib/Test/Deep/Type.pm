use strict;
use warnings;
package Test::Deep::Type;
# ABSTRACT: ...

use parent 'Test::Deep::Cmp';
use Exporter 'import';
use Scalar::Util qw(blessed reftype);
use Safe::Isa;
use Try::Tiny;

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
    my $name = $self->_type_name($self->{type});
    return "Validating $where as a"
        . (defined $name ? ' ' . $name : 'n unknown')
        . ' type';
}

# we do not define a diagnostics sub, so we get the one produced by deep_diag
# showing exactly what part of the data structure failed. This calls renderGot
# and renderVal:

sub renderGot
{
    my $self = shift;
    return defined $self->{error_message} ? $self->{error_message} : 'failed';
}

sub renderExp
{
    my $self = shift;
    return 'no error';
}

sub _is_type
{
    my ($self, $type, $got) = @_;

    if ($type->$_can('validate'))
    {
        $self->{error_message} = $type->validate($got);
        return !defined($self->{error_message});
    }

    # last ditch effort - use the type as a coderef
    if (__isa_coderef($type))
    {
        return try {
            $type->($got)
        } catch {
            $self->{error_message} = $_;
            undef;
        };
    }

    # for now, stringy types are not supported. If a known Moose type, use
    # Moose::Util::TypeConstraints::find_type_constraint('typename').

    $self->{error_message} = "Can't figure out how to use '$type' as a type";
    undef;
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
    return;
}

sub __isa_coderef
{
    ref $_[0] eq 'CODE'
        or (reftype($_[0]) || '') eq 'CODE'
        or overload::Method($_[0], '&{}')
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
