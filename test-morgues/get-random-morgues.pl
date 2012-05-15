#!/usr/bin/env perl

use feature 'say';

my @u;
for(qx[cat user-list-0.10.txt]) {
    push @u, $1 if /^<a href="([^\/]+)/;
}
my @r = map $u[rand @u], 1 .. 10;
for my $user (@r) {
    my @morgues = `GET "http://crawl.develz.org/morgues/0.10/$user"` =~ /(morgue-$user-[\d-]+.txt)/g;
    print("\nNot enough morgues for $user\n\n"), next
        if @morgues <= 10;
    # Just get the first middle and last.
    for my $morgue (@morgues[map rand @morgues, 1 .. 10]) {
        say "Getting morgue for $user - $morgue";
        system wget => "http://crawl.develz.org/morgues/0.10/$user/$morgue";
    }
    sleep 1;
}
