package Getopt::Long::Util;

use 5.010001;
use strict;
use warnings;

our $VERSION = '0.71'; # VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       humanize_getopt_long_opt_spec
                       gospec2human
               );

# old name, kept for backward-compat
sub gospec2human { goto &humanize_getopt_long_opt_spec }

sub humanize_getopt_long_opt_spec {
    my $optspec = shift;

    $optspec =~ s/\A--?//;

    my $type = 'flag';
    if ($optspec =~ s/!$//) {
        $type = 'bool';
    } elsif ($optspec =~ s/(=\w)$//) {
        $type = $1;
    } elsif ($optspec =~ s/\+$//) {
        # also a flag, increment by one like --more --more --more
    } elsif ($optspec !~ /[A-Za-z0-9?]\z/) {
        die "Sorry, can't parse opt spec '$optspec' yet (probably invalid?)";
    }

    my $res = "";
    for (split /\|/, $optspec) {
        $res .= ", " if length($res);
        s/^--?//;
        if ($type eq 'bool') {
            $res .= "--(no)$_";
        } else {
            if (length($_) > 1) {
                $res .= "--$_" . ($type =~ /^=/ ? $type : "");
            } else {
                $res .= "-$_" . ($type =~ /^=/ ? $type : "");
            }
        }
    }
    $res;
}

#ABSTRACT: Utilities for Getopt::Long

__END__

=pod

=encoding UTF-8

=head1 NAME

Getopt::Long::Util - Utilities for Getopt::Long

=head1 VERSION

version 0.71

=for Pod::Coverage ^(gospec2human)$

=head1 FUNCTIONS

=head2 humanize_getopt_long_opt_spec($gospec) => STR

Convert Getopt::Long option specification like C<help|h|?> or <--foo=s> or
C<debug!> into, respectively, C<--help, -h, -?> or C<--foo=s> or C<--(no)debug>.
The output is suitable for including in help/usage text.

=head1 SEE ALSO

L<Getopt::Long>

=head1 HOMEPAGE

Please visit the project's homepage at L<https://metacpan.org/release/Getopt-Long-Util>.

=head1 SOURCE

Source repository is at L<https://github.com/sharyanto/perl-Getopt-Long-Util>.

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website L<https://rt.cpan.org/Public/Dist/Display.html?Name=Getopt-Long-Util>

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
