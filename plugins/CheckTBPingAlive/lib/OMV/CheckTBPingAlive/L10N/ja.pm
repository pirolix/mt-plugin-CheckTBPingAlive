package OMV::CheckTBPingAlive::L10N::ja;
# $Id$

use strict;
use base 'OMV::CheckTBPingAlive::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
    # CheckTBPingAlive.pl
    'Check whether the TBPing&apos;s URL is alive.' => 'トラックバックの送信元 URL が生きているかチェックします。',
    "Check whether all trackback's source URLs are alive" => '全てのトラックバック元 URL の生存確認',
    "Check whether the selected trackback's source URLs are alive" => '選択されたトラックバック元 URL の生存確認',
    "Check whether this trackback's source URL is alive" => 'このトラックバック元 URL の生存確認',
    "Are you sure you want to check aliving of all trackbacks?" => '全てのトラックバックの生存確認を行ってよろしいですか？',

    # tmpl/config.tmpl
    'Published trackback' => '公開済みトラックバック',
    'Moderated trackback' => '未公開のトラックバック',
    'Junked trackback' => 'スパム トラックバック',
    'Select your action when the published trackback is dead' => '公開済みトラックバックが死んでいた場合のアクションを選択します',
    'Select your action when the moderated trackback is dead' => '未公開のトラックバックが死んでいた場合のアクションを選択します',
    'Select your action when the junked trackback is dead' => 'スパム トラックバックが死んでいた場合のアクションを選択します',
    'Skip and no checking' => '(チェックしません)',

    # tmpl/checking.tmpl
    'Checking trackback&apos;s alive' => 'トラックバックの生存確認をしています',

    # tmpl/finish.tmpl
    'Finished trackback alive checking' => 'トラックバックの生存確認が完了',
    'Total checked' => 'チェックした総数',
    'In alive' => '正常',
    'Turn unpublished' => '非公開',
    'Turn junked' => 'スパム指定',
    'Removed' => '削除',
);

1;