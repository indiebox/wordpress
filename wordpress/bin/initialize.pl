#!/usr/bin/perl
#
# Initialize freshly installed Wordpress. Only invoke from indie-box-manifest.json.
#
# Watch out for quotes etc. Perl and PHP use the same way of naming variables.
#

use strict;

use IndieBox::Logging;
use IndieBox::Utils;

if( 'install' eq $operation ) {
    my $dir  = $config->getResolve( 'appconfig.apache2.dir' );
    my $cmd  = "cd $dir/wp-admin ;";
    $cmd    .= ' HTTP_HOST='     . $config->getResolve( 'site.hostname' );
    $cmd    .= ' REQUEST_URI='   . $config->getResolve( 'appconfig.context' );
    $cmd    .= ' APPCONFIG_DIR=' . $dir;
    $cmd    .= ' php';
    $cmd    .= ' -d "open_basedir=\'/srv/http/:/home/:/tmp/:/usr/share/pear/:/usr/share/webapps/:/usr/share/wordpress/wordpress/\'"';
        # use default open_basedir and append Wordpress

    my $title      = $config->getResolve( 'installable.customizationpoints.title.value' );
    my $adminname  = $config->getResolve( 'site.admin.userid' );
    my $adminpass  = $config->getResolve( 'site.admin.credential' );
    my $adminemail = $config->getResolve( 'site.admin.email' );

    $title      = IndieBox::Utils::escapeSquote( $title );
    $adminname  = IndieBox::Utils::escapeSquote( $adminname );
    $adminpass  = IndieBox::Utils::escapeSquote( $adminpass );
    $adminemail = IndieBox::Utils::escapeSquote( $adminemail );

    my $php = <<PHP;
<?php
\$_SERVER['SERVER_PROTOCOL'] = 'HTTP/1.1';
\$_SERVER['PHP_SELF']        = 'wp-admin/install.php';

\$_GET['step'] = 2;

\$_POST['weblog_title']    = '$title';
\$_POST['user_name']       = '$adminname';
\$_POST['admin_password']  = '$adminpass';
\$_POST['admin_password2'] = \$_POST['admin_password'];
\$_POST['admin_email']     = '$adminemail';
\$_POST['Submit']          = 'Install WordPress';

require_once( '../wp-blog-header.php' );
require_once( 'install.php' );
PHP

    my $out = '';
    my $err = '';

    # pipe PHP in from stdin
    debug( 'About to execute PHP', $php );

    if( IndieBox::Utils::myexec( $cmd, $php, \$out, \$err ) != 0 ) {
        error( 'Initializing Wordpress failed:', $err );
    }
}

1;

