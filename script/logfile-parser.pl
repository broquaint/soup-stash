use strict;
use warnings;

use JSON 'to_json';
use Data::Dumper 'Dumper';

# We should be chdir'ed to vendor/dcss_henzell at this point
require 'sqllog.pl';

# Needed so parent can read straightway otherwise it blocks on output.
$|=1;

while(<>) {
    chomp(my $line = $_);
    # Parent process indicates we're done here.
    last if $line eq '__EXIT__';

    # server is lies to keep the code happy (think it's ok to lie?)
    my $game = build_fields_from_logline({server => 'cao'}, tell(*STDIN), $line);
    if(ref $game) {
      print to_json($game);
    } else {
      warn sprintf "$0: Couldn't parse:\n\n%s\n\nGot back - %s\n\n",
           $line, Dumper($game);
    }

    print "\n"; # Indicate we've finished output.
}

exit 0;

=pod

To be invoked by C<ingestlogfile> with C<STDIN> and C<STDOUT> set up as
appropriate.

=cut
