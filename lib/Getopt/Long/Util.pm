package Getopt::Long::Util;

use 5.010001;
use strict;
use warnings;
use experimental 'smartmatch';

our $DATE = '2014-07-23'; # DATE
our $VERSION = '0.75'; # VERSION

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(
                       parse_getopt_long_opt_spec
                       humanize_getopt_long_opt_spec
               );

sub parse_getopt_long_opt_spec {
    my $optspec = shift;
    $optspec =~ qr/\A
               (?:--)?
               (?P<name>[A-Za-z0-9_][A-Za-z0-9_-]*)
               (?P<aliases> (?: \| (?:[^:|!+=:-][^:|!+=:]*) )*)?
               (?:
                   (?P<is_neg>!) |
                   (?P<is_inc>\+) |
                   (?:
                       =
                       (?P<type>[siof])
                       (?P<desttype>|[%@])?
                       (?:
                           \{
                           (?: (?P<min_vals>\d+), )?
                           (?P<max_vals>\d+)
                           \}
                       )?
                   ) |
                   (?:
                       :
                       (?P<opttype>[siof])
                       (?P<desttype>|[%@])
                   ) |
                   (?:
                       :
                       (?P<optnum>\d+)
                       (?P<desttype>|[%@])
                   )
                   (?:
                       :
                       (?P<optplus>\+)
                       (?P<desttype>|[%@])
                   )
               )?
               \z/x
                   or return undef;
    my %res = %+;

    if ($res{aliases}) {
        my @als;
        for (split /\|/, $res{aliases}) {
            next unless length;
            next if $_ eq $res{name};
            next if $_ ~~ @als;
            push @als, $_;
        }
        $res{opts} = [$res{name}, @als];
    } else {
        $res{opts} = [$res{name}];
    }
    delete $res{name};
    delete $res{aliases};

    $res{is_neg} = 1 if $res{is_neg};
    $res{is_inc} = 1 if $res{is_inc};

    $res{normalized} = join(
        "",
        join("|", sort {
            # we sort but put alphanumeric option first
            my $a_is_alpha = $a =~ /^[A-Za-z0-9]/ ? 1:0;
            my $b_is_alpha = $b =~ /^[A-Za-z0-9]/ ? 1:0;
            $b_is_alpha <=> $a_is_alpha || $a cmp $b;
        } @{ $res{opts} }),
        ($res{is_neg} ? "!" : $res{is_inc} ? "+" : ""),
        ($res{type} ? ("=", $res{type}, $res{desttype},
                       (defined($res{max_vals}) ? (defined($res{min_vals}) ? "{$res{min_vals},$res{max_vals}}" : "{$res{max_vals}}") : ())) : ()),
        ($res{opttype} ? (":", $res{opttype}, $res{desttype}) : ()),
        (defined($res{optnum}) ? (":", $res{optnum}, $res{desttype}) : ()),
        ($res{optplus} ? (":", $res{optplus}, $res{desttype}) : ()),
    );
    if (defined $res{max_vals}) {
        $res{min_vals} //= $res{max_vals};
    }
    \%res;
}

sub humanize_getopt_long_opt_spec {
    my $optspec = shift;

    my $parse = parse_getopt_long_opt_spec($optspec)
        or die "Can't parse opt spec $optspec";

    # put long name first (--help before -h) & letter first (-h before -?)
    my @opts = sort {
        (length($a) >1 ? 0:1) <=> (length($b) >1 ? 0:1) ||
            ($a =~ /\A[A-Za-z]/ ? 0:1) <=> ($b =~ /\A[A-Za-z]/ ? 0:1) ||
                $a cmp $b
    } @{ $parse->{opts} };

    my $res = '';
    my $i = 0;
    for (@opts) {
        $i++;
        $res .= ", " if length($res);
        if ($parse->{is_neg} && length($_) > 1) {
            $res .= "--(no)$_";
        } else {
            if (length($_) > 1) {
                $res .= "--$_";
            } else {
                $res .= "-$_";
            }
            $res .= "=$parse->{type}" if $i==1 && $parse->{type};
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

This document describes version 0.75 of Getopt::Long::Util (from Perl distribution Getopt-Long-Util), released on 2014-07-23.

=head1 FUNCTIONS

=head2 parse_getopt_long_opt_spec($str) => hash

Parse Getopt::Long option specification. Will produce a hash with some keys:
C<opts> (array of option names), C<type> (string, type name), C<desttype>
(either '', or '@' or '%'), C<is_neg> (true for C<--opt!>), C<is_inc> (true for
C<--opt+>), C<min_vals> (int, usually 0 or 1), C<max_vals> (int, usually 0 or 1
except for option that requires multiple values), C<normalized> (string,
normalized form of C<$str>: '--' prefix will be stripped, options will be
sorted). Will return undef if it can't parse C<$str>. Examples:

 $res = parse_getopt_long_opt_spec('help|h|?'); # {opts=>['?','h','help'], type=>undef, num_vals=>1}
 $res = parse_getopt_long_opt_spec('--foo=s');  # {opts=>['foo'], type=>'s', num_vals=>1}

=head2 humanize_getopt_long_opt_spec($str) => str

Convert L<Getopt::Long> option specification like C<help|h|?> or <--foo=s> or
C<debug!> into, respectively, C<--help, -h, -?> or C<--foo=s> or C<--(no)debug>.
Will die if can't parse C<$str>. The output is suitable for including in
help/usage text.

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
