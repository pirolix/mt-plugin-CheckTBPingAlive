package MT::Plugin::Trackback::OMV::CheckTBPingAlive;
# CheckTBPingAlive (C) 2010-2012 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id: PluginTemplate.pl 306 2012-11-23 16:28:39Z pirolix $

use strict;
use warnings;
use MT 5;

use vars qw( $VENDOR $MYNAME $FULLNAME $VERSION $SCHEMA_VERSION );
$FULLNAME = join '::',
        (($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1]);
(my $revision = '$Rev: 306 $') =~ s/\D//g;
$VERSION = 'v0.10'. ($revision ? ".$revision" : '');

sub ACTION_NONE     { 0 }
sub ACTION_MODERATE { 1 }
sub ACTION_JUNK     { 2 }
sub ACTION_DELETE   { 3 }

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    # Basic descriptions
    id => $FULLNAME,
    key => $FULLNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2010/01311442/', # Blog
    doc_link => "http://lab.magicvox.net/trac/mt-plugins/wiki/$MYNAME", # tracWiki
    description => <<'HTMLHEREDOC',
<__trans phrase="Check whether the TBPing&apos;s URL is alive.">
HTMLHEREDOC
    l10n_class => "${FULLNAME}::L10N",

    # Configurations
    system_config_template => "$VENDOR/$MYNAME/config.tmpl",
    settings => new MT::PluginSettings ([
        [ 'check_published', { Default => ACTION_NONE(), scope => 'system' } ],
        [ 'check_moderated', { Default => ACTION_NONE(), scope => 'system' } ],
        [ 'check_junked', { Default => ACTION_NONE(), scope => 'system' } ],
    ]),

    # Registry
    registry => {
        applications => {
            cms => {
                content_actions => {
                    ping => {
                        hogehoge => {
                            label   => "Check whether all trackback's source URLs are alive",
                            class   => 'icon-action',
                            mode    => lc join ('_', $VENDOR, 'check_tbping_alive'),
                            return_args => 1,
                            confirm_msg => sub {
                                &instance->translate ("Are you sure you want to check aliving of all trackbacks?");
                            },
                        },
                    },
                },
                list_actions => {
                    ping => {
                        hogehoge => {
                            label   => "Check whether the selected trackback's source URLs are alive",
                            mode    => lc join ('_', $VENDOR, 'check_tbping_alive'),
                        },
                    },
                },
                page_actions => {
                    ping => {
                        hogehoge => {
                            label   => "Check whether this trackback's source URL is alive",
                            mode    => lc join ('_', $VENDOR, 'check_tbping_alive'),
                       },
                    },
                },
                methods => {
                    lc join ('_', $VENDOR, 'check_tbping_alive') => "${FULLNAME}::Methods::check_tbping_alive",
                },
            },
        },
    },
});
MT->add_plugin ($plugin);

sub instance { $plugin; }

1;