package Egg::Plugin::SessionKit::Bind::Cookie;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cookie.pm 136 2007-05-12 12:49:36Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit::Bind::Cookie - Session ID delivery by Cookie.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      bind => {
        name          => 'Cookie',
        cookie_name   => 'sid',
        cookie_path   => '/',
        cookie_domain => 'www.hoge.domain.name',
        cookie_secure => 1,
        },
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
use strict;
use warnings;

our $VERSION= '2.00';

=head1 METHODS

=head2 startup

The setting is checked.

=cut
sub startup {
	my($class, $e, $conf)= @_;
	my $bind= $conf->{bind} ||= {};
	$bind->{cookie_name} ||= 'ss';
	$bind->{cookie_path} ||= '/';
	$bind->{cookie_secure} = 1 unless defined($bind->{cookie_secure});
	$class->next::method($e, $conf);
}

=head2 get_bind_data

Session id is received from Cookie.

=cut
sub get_bind_data {
	my $ss = shift;
	my $key= shift || $ss->config->{bind}{cookie_name};
	$ss->e->request->cookie_value($key) || 0;
}

=head2 set_bind_data

It prepares it. bury session id under the response header

=cut
sub set_bind_data {
	my $ss  = shift;
	my $conf= $ss->config->{bind};
	my $key = shift || $conf->{cookie_name};
	my $id  = shift || die q{ I want bind_id };
	my $args= shift || {};
	$args->{value}= $id;
	$args->{path} ||= $conf->{cookie_path};
	$args->{domain} = $conf->{cookie_domain}
	  if (! $args->{domain} and $conf->{cookie_domain});
	$args->{expires}= $conf->{cookie_expires}
	  if (! $args->{expires} and $conf->{cookie_expires});
	$args->{secure}= 1
	  if ($conf->{cookie_secure} and $ss->e->request->secure);
	$ss->e->response->cookies->{$key}= $args;
}

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
