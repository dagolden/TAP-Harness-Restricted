use 5.008001;
use strict;
use warnings;

package TAP::Harness::Restricted;
# ABSTRACT: Skip some test files
# VERSION

use superclass 'TAP::Harness' => 3.18;
use Path::Tiny;

sub aggregate_tests {
    my ($self, $aggregate, @tests) = @_;
    @tests = grep { _file_ok($_) } @tests;
    return $self->SUPER::aggregate_tests($aggregate, @tests);
}

my $maybe_prefix = qr/(?:\d+[_-]?)?/;

my @banned_names = (
    qr/${maybe_prefix}pod\.t/,
    qr/${maybe_prefix}pod[_-]?coverage\.t/,
);

my @banned_code = (
    qr/use Test::Pod/, # also gets Test::Pod::Coverage
);

sub _file_ok {
    my $file = path(shift);
    return unless $file->exists;
    my $basename = $file->basename;
    return if grep { $basename =~ $_ } @banned_names;
    my $guts = $file->slurp;
    return if grep { $guts =~ m{$_}ms } @banned_code;
    return 1;
}


1;

=for Pod::Coverage method_names_here

=head1 SYNOPSIS

    # command line
    $ HARNESS_SUBCLASS=TAP::Harness::Restricted make test

    # bashrc file
    export HARNESS_SUBCLASS=TAP::Harness::Restricted

=head1 DESCRIPTION

This module is a trivial subclass of L<TAP::Harness>.  It overrides the
C<aggregate_tests> function to filter out tests that I didn't want getting in
the way of module installation.

The current criteria include:

=for :list
* File names that look like F<pod.t> or F<pod-coverage.t>, with optional leading numbers
* Files that contain the text C<use Test::Pod>

Suggestions for other annoying things to filter out are welcome.

If someone is inclined to make this extensible so people can put their own criteria into
configuration files, please email the author with ideas before sending a patch.

=cut

# vim: ts=4 sts=4 sw=4 et:
