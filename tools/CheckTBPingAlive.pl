#!/usr/bin/perl
# $Id$

use strict;
use warnings;
use lib qw(lib ../lib ../extlib extlib);
use MT;
use MT::Blog;
use MT::TBPing;
binmode STDOUT, ":utf8";
$|++;

unless (@ARGV) {
    print "Usage: $0 <Blog ID> ...\n";
    exit;
}

my $mt = MT->new or die;
$MT::DebugMode = 0;
my $ua = $mt->new_ua or die;

while (my $blog_id = shift @ARGV) {
    my $blog = MT::Blog->load($blog_id);
    if (!$blog) {
        printf "A blog of id=%d not found. skipped.\n", $blog_id;
        next;
    }

    my $total_pings = MT::TBPing->count({ blog_id => $blog->id });
    printf "Blog '%s' (id=%d) has %d trackback pings.\n", $blog->name, $blog->id, $total_pings;

    for (my $i = 0; $i < $total_pings; $i++) {
        my $tbping = MT::TBPing->load ({ blog_id => $blog->id }, { sort => 'id', direction => 'ascend', offset => $i }) or next;
        printf "[%s/%s] %s\n", ($i+1), $total_pings, $tbping->source_url;
        my $res = $ua->get ($tbping->source_url);
        if (!$res || !$res->is_success) {
            # 公開されているトラックバック → トラックバックの公開取り消し
            if ($tbping->is_published()) {
                printf "\tPublished -> Moderated\n";
                $tbping->moderate;
                $tbping->save;
            }
            # 公開されていないトラックバック → スパムトラックバック
            elsif ($tbping->is_moderated()) {
                printf "\tModerated -> Junk\n";
                $tbping->junk;
                $tbping->save;
            }
            # スパムトラックバック → 削除
            elsif ($tbping->is_junk()) {
                printf "\tJunk -> Removed\n";
                $tbping->remove;
            }
        } else {
            printf "\tOK\n";
        }
    }
}
