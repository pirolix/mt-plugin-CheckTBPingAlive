package OMV::CheckTBPingAlive::Methods;
# CheckTBPingAlive (C) 2010-2012 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id$


use strict;
use warnings;
use MT;

use vars qw( $VENDOR $MYNAME $FULLNAME );
$FULLNAME = join '::',
        (($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[0, 1]);

sub instance { MT->component($FULLNAME); }



### omv_sample_methods
sub check_tbping_alive {
    my ($app) = @_;
    my %param;

    $param{__mode} = $app->param ('__mode')
        or return $app->error (&instance->translate ('Invalid request'));

    $app->validate_magic
        or return $app->error (&instance->translate ('Invalid request'));
    $param{magic_token} = $app->param ('magic_token');

    defined (my $blog = $app->blog)
        or return $app->error (&instance->translate ('Invalid blog_id'));
    $param{blog_id} = my $blog_id = $blog->id;

    $app->param ('from') eq 'view'
        and $app->param ('_type', 'ping');
    defined (my $_type = $app->param ('_type'))
        or return $app->error (&instance->translate ('Invalid [_1] parameter.', '_type'));
    (my $class = MT->model ($_type)) eq 'MT::TBPing'
        or return $app->error (&instance->translate ('Invalid [_1] parameter.', '_type'));
    $param{_type} = $_type;

    (my $return_args = $app->param ('return_args'))
        or return $app->error (&instance->translate ('Invalid [_1] parameter.', 'return_args'));
    $param{return_args} = $return_args;

    $param{cnt_total} = $app->param ('cnt_total') || 0;
    $param{cnt_alive} = $app->param ('cnt_alive') || 0;
    $param{cnt_unpub} = $app->param ('cnt_unpub') || 0;
    $param{cnt_junk} = $app->param ('cnt_junk') || 0;
    $param{cnt_delete} = $app->param ('cnt_delete') || 0;

    # Finish of all checking
    return &instance->load_tmpl ("$VENDOR/$MYNAME/finish.tmpl", \%param)
        if $app->param ('finish');

    # Retrieve configurations
    my $settings = &instance->get_config_hash();

    # Load TBPing to be checked
    my $tbping;
    if (my @id = $app->param ('id')) {
        $param{cnt_total} ||= my $cnt_total = scalar @id;

        my $id = shift @id;
        $tbping = $class->load ({ id => $id, blog_id => $blog_id });

        $param{cnt_current} = $cnt_total - scalar @id;
        @id
            ? $param{id} = join ',', @id
            : $param{finish} = 1;
    }
    else {
        $param{cnt_total} ||= my $cnt_total = $class->count ({ blog_id => $blog_id });

        my $cnt_current = $app->param ('cnt_current') || 0;
        $tbping = $class->load ({ blog_id => $blog_id }, { offset => $cnt_current, limit => 1, sort_by => 'id' });

        $param{cnt_current} = $cnt_current + 1;
        $param{finish} = ($cnt_total <= $param{cnt_current});
    }

    if (!$tbping) {
        $param{object_not_found} = 1;
        goto OUTPUT;
    }

    $param{site_title} = $tbping->blog_name;
    $param{article_title} = $tbping->title;
    $param{article_url} = $tbping->source_url;

    if (    $tbping->is_published && $settings->{check_published} == &instance->ACTION_NONE
        ||  $tbping->is_moderated && $settings->{check_moderated} == &instance->ACTION_NONE
        ||  $tbping->is_junk && $settings->{check_junked} == &instance->ACTION_NONE) {
        $param{ping_status} = &instance->translate ('Skip');
        goto OUTPUT;
    }

    # Checking
    my $ua = MT->new_ua ({ timeout => MT->config->PingTimeout });
    $ua->agent (sprintf '%s/%s (%s)', &instance->name, &instance->version, &instance->doc_link);
    my $res = $ua->get ($tbping->source_url);

    if ($res && $res->is_success) {
        $param{cnt_alive}++;
        $param{ping_status} = $res->status_line;
        goto OUTPUT;
    }
    $param{ping_status} = $res
        ? $res->status_line
        : __LINE__;

    my $action = &instance->ACTION_NONE;
    $action = $settings->{check_published} if $tbping->is_published;
    $action = $settings->{check_moderated} if $tbping->is_moderated;
    $action = $settings->{check_junked} if $tbping->is_junk;
    if ($action == &instance->ACTION_MODERATE) {
        $tbping->moderate;
        $tbping->save;
        $param{action} = &instance->translate ('Turn unpublished');
        $param{cnt_unpub}++;
    }
    elsif ($action == &instance->ACTION_JUNK) {
        $tbping->junk;
        $tbping->save;
        $param{action} = &instance->translate ('Turn junked');
        $param{cnt_unpub}++;
    }
    elsif ($action == &instance->ACTION_DELETE) {
        $tbping->remove;
        $param{action} = &instance->translate ('Removed');
        $param{cnt_delete}++;
    }

OUTPUT:
    return &instance->load_tmpl ("$VENDOR/$MYNAME/checking.tmpl", \%param);
}

1;