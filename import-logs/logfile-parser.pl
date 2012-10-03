use strict;
use warnings;

use YAML ();

# We should be chdir'ed to /home/dbrook/dev/dcss_henzell at this point
do 'sqllog.pl';

# Needed so parent can read straightway otherwise it blocks on output.
$|=1;

while(<>) {
    chomp(my $line = $_);
    # Parent process indicates we're done here.
    last if $line eq '__EXIT__';

    # FIXME - Assumes cszo as the server, takes as an argument probably.
    print YAML::Dump(
	build_fields_from_logline({server => 'cszo'}, tell(*STDIN), $line)
    );
    print '__EOF__', $/; # Indicate we've finished YAML output.
}

exit 0;

=pod

To be invoked by C<ingest-log-lines> with C<STDIN> and C<STDOUT> set up as
appropriate.

=cut
