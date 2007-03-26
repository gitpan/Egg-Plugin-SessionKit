package Egg::Plugin::SessionKit::Bind::Cookie;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Cookie.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;

our $VERSION= '0.03';

sub startup {
	my($class, $e, $conf)= @_;
	$conf->{bind}{cookie_name} ||= 'ss';
	$conf->{bind}{cookie_path} ||= '/';
	$conf->{bind}{cookie_secure}= 1
	  unless defined($conf->{bind}{cookie_secure});
	$class->next::method($e, $conf);
}
sub get_bind_data {
	my $ss = shift;
	my $key= shift || $ss->config->{bind}{cookie_name};
	my $cookie= $ss->e->request->cookie($key) || return 0;
	$cookie->value || 0;
}
sub set_bind_data {
	my $ss  = shift;
	my $conf= $ss->config->{bind};
	my $key = shift || $conf->{cookie_name};
	my $id  = shift || Egg::Error->throw(q/I want bind_id/);
	my $args= shift || {};
	$args->{value}  = $id;
	$args->{path} ||= $conf->{cookie_path};
	$args->{domain} = $conf->{cookie_domain}
	  if (! $args->{domain} && $conf->{cookie_domain});
	$args->{expires}= $conf->{cookie_expires}
	  if (! $args->{expires} && $conf->{cookie_expires});
	$args->{secure}= 1
	  if ($conf->{cookie_secure} && $ss->e->request->secure);
	$ss->e->response->cookies->{$key}= $args;
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Bind::Cookie - Session ID is handed over by using the cookie.

=head1 SYNOPSIS

Configuration.

  plugin_session=> {
    bind=> {
      name=> 'Cookie',
      cookie_name  => 'session_id',
      cookie_path  => '/',
      cookie_secure=> 1,
      },
    },

=over 4

=item get_bind_data, set_bind_data, startup,

These methods are called from the base module.

=back

=head1 CONFIGURATION

$e->config->{plugin_session}{bind} becomes setup of this module.

=head2 name

Please always specify 'B<Cookie>' if you use this module.

=head2 cookie_name

It is a name of the cookie used when handing it over.

B<Default is 'ss'>

=head2 cookie_path

It is a setting of passing by making the cookie effective.
When the subdirectory is specified here, session ID cannot be received by the above
 hierarchy.

B<Default is '/'>

=head2 cookie_domain

Please specify it when the host as whom the domain name is the same wants to share
 session ID by you.

B<Default is none.>

=head2 cookie_expires

The expiration date of Cookie is set. You will not set it usually.

B<Default is none.>

=head2 cookie_secure

It is communicated with SSL and if cookie_secure is true, the cookie with the secure flag 
is issued.

Cookie_secure adheres at a usual access and the secure flag doesn't adhere to true 
either.

HTTP and HTTPS are managed in the same way. 
Because Cookie with the secure flag is not seen from HTTP, the session issued with HTTPS is 
annulled. 

=head1 SEE ALSO

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
