use strict;
use warnings;

use JSON 'to_json';

# We should be chdir'ed to /home/dbrook/dev/dcss_henzell at this point
do 'sqllog.pl';

# Needed so parent can read straightway otherwise it blocks on output.
$|=1;

while(<>) {
    chomp(my $line = $_);
    # Parent process indicates we're done here.
    last if $line eq '__EXIT__';

    print to_json(
        # server is lies to keep the code happy (think it's ok to lie?)
	build_fields_from_logline({server => 'cao'}, tell(*STDIN), $line)
    );
    print "\n__EOF__\n"; # Indicate we've finished output.
}

exit 0;

=pod

To be invoked by C<ingestlogfile> with C<STDIN> and C<STDOUT> set up as
appropriate.

=cut
