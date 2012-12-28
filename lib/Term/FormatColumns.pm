package Term::FormatColumns;
{
  $Term::FormatColumns::VERSION = '0.001';
}

use Sub::Exporter -setup => [
    exports => [
        'format_list',
    ],
];

use Term::ReadKey qw( GetTerminalSize );
use List::Util qw( max );
use List::MoreUtils qw( part each_arrayref );
use POSIX qw( ceil );

sub format_list(@) {
    return format_to_fh( \*STDOUT, @_ );
}

sub format_to_fh {
    my ( $fh, @data ) = @_;
 
    # If we're not attached to a terminal, one column, seperated by newlines
    if ( !-t $fh ) {
        return join "\n", @data;
    }
 
    # We're attached to a terminal, print column-wise alphabetically to fit the
    # terminal width
    my ( $term_width, undef, undef, undef ) = GetTerminalSize();
    my $max_width = max map { length } @data;
    $max_width += 2; # make sure at least two spaces between data values
    my $columns = int( $term_width / $max_width );
    if ( $columns <= 1 ) {
        # Only one column, let the terminal handle things
        return join "\n", @data;
    }
    my $output = '';
    my $column_width = int( $term_width / $columns );
    my $format = "\%-${column_width}s" x $columns . "\n";
    my $rows = ceil( @data / $columns );
    my @index = part { int( $_ / $rows ) } 0..$#data;
    my $iter = each_arrayref @index;
    while ( my @row_vals = $iter->() ) {
        $output .= sprintf $format, map { $data[$_] } @row_vals;
    }
    return $output;
}

1;

=head1 NAME

Term::FormatColumns - Format lists of data into columns across the terminal's width

=head1 SYNOPSIS

    use Term::FormatColumns qw( format_list );
    my @list = 0..1000;
    print format_list @list;

=head1 DESCRIPTION

This module will take a list and format it into columns that stretch across the
current terminal's width, much like the output of ls(1).

If the filehandle is not attached to a tty, will simply write one column of output
(again, like ls(1)).

=head1 FUNCTIONS

=head2 format_list

Format the list of data. Returns a single string formatted and ready for output.

=head1 COPYRIGHT

Copyright 2012, Doug Bell <preaction@me.com>

=head1 LICENSE

This distribution is free software; you can redistribute it and/or modify it
under the same terms as Perl 5.14.2.

This program is distributed in the hope that it will be
useful, but without any warranty; without even the implied
warranty of merchantability or fitness for a particular purpose.
