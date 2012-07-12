#!/usr/bin/env perl

use strict;
use warnings;

use feature 'say';

my @u;
for(qx[cat user-list-0.10.txt]) {
    push @u, $1 if /^<a href="([^\/]+)/;
}
my @r = map $u[rand @u], 1 .. 20;
for my $user (@r) {
    my @all_morgues = `GET "http://crawl.develz.org/morgues/0.10/$user"` =~ /(morgue-$user-[\d-]+.txt)/g;
    print("\nNot enough morgues for $user\n\n"), next
        if @all_morgues <= 25;
    my @rand_morgues = map splice(@all_morgues, rand @all_morgues, 1), 1 .. 25;
    for my $morgue (@rand_morgues) {
        say "Getting morgue for $user - $morgue";
        system wget => "http://crawl.develz.org/morgues/0.10/$user/$morgue";
    }
    sleep 2;
}
