#!/usr/bin/perl
use strict;
use Bibliotech::DBI;

# remove bookmarks that have no postings (and their linked citations)

my $dbh = Bibliotech::DBI->db_Main();
my $sth = $dbh->prepare('select bookmark_id from bookmark b left join user_bookmark ub on (b.bookmark_id=ub.bookmark) where ub.user_bookmark_id is null');
$sth->execute;
print $sth->rows." bookmarks\n";
while (my ($bookmark_id) = $sth->fetchrow_array) {
  print "del $bookmark_id\n";
  eval { Bibliotech::Bookmark->retrieve($bookmark_id)->delete; };
  warn $@ if $@;
}
