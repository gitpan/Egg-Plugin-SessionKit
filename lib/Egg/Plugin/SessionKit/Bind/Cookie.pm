package Egg::Plugin::SessionKit::Bind::Cookie;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cookie.pm 214 2007-11-06 13:51:19Z lushe $
#
use strict;
use warnings;

our $VERSION= '2.10';

=head1 NAME

Egg::Plugin::SessionKit::Bind::Cookie - Session ID delivery by Cookie.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->egg_startup(
    .......
    ...
    
    plugin_session => {
      component=> [
        [ 'Base::Module' => { ... } ],
        [ 'Bind::Cookie' => {
          cookie_name   => 'sid',
          cookie_path   => '/',
          cookie_domain => 'www.hoge.domain.name',
          cookie_expires=> '+1d',
          cookie_secure => 1,
          } ],
        qw/ Store::Plain /,
        ],
      },
    );

=head1 DESCRIPTION

Session id is handed over by Cookie with the client.

=head1 CONFIGRATION

=head2 cookie_name

Name of parameter used to refer to Cookie.

=head2 cookie_path

PATH that enables reference to Cookie.

=head2 cookie_domain

Domain name that enables reference to Cookie.

=head2 cookie_secure

When SSL is communicated, the secure flag is made effective when an effective
value is set.

=head2 cookie_expires

Validity term of Cookie.

You will not set it usually.

=cut
sub startup {
	my($class, $e, $conf)= @_;
	my $cf= $conf->{bind_cookie};
	$cf->{cookie_name} ||= 'ss';
	$cf->{cookie_path} ||= '/';
	$cf->{cookie_secure} = 1 unless defined($cf->{cookie_secure});
	$class->next::method($e, $conf);
}
sub get_bind_data {
	my $ss = shift;
	my $key= shift || $ss->mod_conf->{bind_cookie}{cookie_name};
	$ss->e->request->cookie_value($key) || $ss->is_session_id || 0;
}
sub set_bind_data {
	my $ss  = shift;
	my $key = shift || "";
	my $id  = shift || $ss->is_session_id;
	my $args= shift || {};
	my $cf  = $ss->mod_conf->{bind_cookie};
	$key= $cf->{cookie_name} if $cf->{cookie_name};
	$args->{value}= $id;
	$args->{path} ||= $cf->{cookie_path};
	$args->{domain} = $cf->{cookie_domain}
	   if (! $args->{domain} and $cf->{cookie_domain});
	$args->{expires}= $cf->{cookie_expires}
	   if (! $args->{expires} and $cf->{cookie_expires});
	$args->{secure}= 1
	   if ($cf->{cookie_secure} and $ss->e->request->secure);
	$ss->e->response->cookies->{$key}= $args;
}

=head1 METHODS

=head2 startup

The setting is checked.

=head2 get_bind_data

Session id is received from Cookie.

=head2 set_bind_data

It prepares it. bury session id under the response header

=head1 SEE ALSO

L<Egg::Response>,
L<Egg::Plugin::SessionKit>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
