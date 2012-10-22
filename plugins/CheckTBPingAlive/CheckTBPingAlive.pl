package MT::Plugin::OMV::CheckTBPingAlive;
# $Id$

use strict;

use vars qw( $VENDOR $MYNAME $VERSION );
($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1];
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = '0.01'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new({
        id => $MYNAME,
        key => $MYNAME,
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Open MagicVox.net',
        author_link => 'http://www.magicvox.net/',
        doc_link => 'http://www.magicvox.net/',
        description => <<HTMLHEREDOC,
Check whether the TBPing&apos;s URL is alive.
HTMLHEREDOC
});
MT->add_plugin( $plugin );

sub instance { $plugin; }

### Registry
sub init_registry {
    my $plugin = shift;
    $plugin->registry({
        applications => {
            cms => {
                menus => {
                    "tools:$MYNAME" => {
                        label => 'Check TBPing&apos;s alive',
                        mode => 'check_tbping_alive',
                        permission => 'create_post,edit_all_posts,manage_feedback',
                        view => 'blog',
                    },
                },
                methods => {
                    check_tbping_alive => "\$${MYNAME}::${MYNAME}::_hdlr_check_tbping_alive",
                },
            },
        },
    });
}

1;
__END__