package CheckTBPingAlive;

use strict;
use MT;
use MT::App;
use MT::TBPing;
use MT::Trackback;
use MT::Entry;
use LWP::UserAgent;

sub instance { MT->component(__PACKAGE__); }

sub _hdlr_check_tbping_alive {
    my ($app) = @_;

    my $blog_id = $app->param ('blog_id')
        or return $app->error (MT->translate ('Invalid blog ID \'[_1]\'', ''));
    ### Need configurations before checking
    my $next = $app->param ('next');
    return &instance->load_tmpl ('config.tmpl')
        if !defined $next;

    ### Finish checking overall
    my $total = MT::TBPing->count ({ blog_id => $blog_id });
    return &instance->load_tmpl ('config.tmpl', { done => 1 })
        if $total <= $next;

    ### Load a TBPing
    my $tbping = MT::TBPing->load ({
        blog_id => $blog_id,
    }, {
        sort => 'id', direction => 'ascend', offset => $next, limit => 1,
    }) or return &instance->load_tmpl ('config.tmpl', { done => 1 });

    ### Checking
    my $ua = LWP::UserAgent->new
        or return qq{ Can&apos;t initialize "LWP::UserAgent" };
    $ua->timeout (30);
    $ua->agent (sprintf '%s/%s (%s)', &instance->name, &instance->version, &instance->doc_link);
    my $url = $tbping->source_url;
    my $res = $ua->get ($url);

    my $param = {
        blog_id => $blog_id,
        url => $url,
        blog_name => $tbping->blog_name,
        title => $tbping->title,
        unpublish => $app->param ('unpublish') || 0,
        junk => $app->param ('junk') || 0,
        delete => $app->param ('delete') || 0,
        rebuild => $app->param ('rebuild') || 0,
        ratio => int ($next * 100 / $total),
        next => ++$next,
        action => MT->translate ('Advanced TrackBack Lookups'). ' OK',
    };
    if (!defined $res || !$res->is_success) {
        # 公開されているトラックバック ≫ トラックバックの公開取り消し
        if ($tbping->is_published() && $app->param ('unpublish')) {
            $param->{action} = MT->translate ('Unpublish TrackBack(s)');
                $tbping->moderate;
                $tbping->save;
                _rebuild_entry ($app, $tbping);
        }
        # 公開されていないトラックバック ≫ スパムトラックバック
        elsif ($tbping->is_moderated() && $app->param ('junk')) {
            $param->{action} = MT->translate ('Junk TrackBacks');
                $tbping->junk;
                $tbping->save;
                _rebuild_entry ($app, $tbping);
        }
        # スパムトラックバック ≫ 削除
        elsif ($tbping->is_junk() && $app->param ('delete')) {
            $param->{action} = MT->translate ('Delete');
                $tbping->remove;
                _rebuild_entry ($app, $tbping);
        }
        else {
            $param->{action} = MT->translate ('Skip');
        }
    }
    &instance->load_tmpl ('checking.tmpl', $param);
}

sub _rebuild_entry {
    my ($app, $tbping) = @_;

    return if !$app->param ('rebuild');

    my $tb = MT::Trackback->load ($tbping->tb_id)
        or return;
    my $entry = MT::Entry->load ($tb->entry_id)
        or return;
=pod
    $app->rebuild_entry (
        Entry => $entry->id,
        Blog => $entry->blog_id,
        BuildDependencies => 1,
    );
=cut
}

1;