package Egg::Plugin::SessionKit::Base::FileCache;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: FileCache.pm 136 2007-05-12 12:49:36Z lushe $
#

=head1 NAME

Egg::Plugin::SessionKit::Base::FileCache - Cache::FileCache for Session.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    plugin_session => {
      base => {
        name        => 'FileCache',
        cache_root  => '/path/to/cache',
        namespace   => 'sessions',
        cache_depth => 3,
        default_expires_in => (60* 60),
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

The session by L<Cache::FileCache> is supported.

=head1 CONFIGRATION

The setting becomes an option to pass everything to L<Cache::FileCache>.

Please refer to the document of L<Cache::FileCache>.

=cut
use strict;
use warnings;
use Cache::FileCache;

our $VERSION= '2.00';

__PACKAGE__->mk_accessors('cache');

=head1 METHODS

=head2 startup

The setting is checked.

=cut
sub startup {
	my($class, $e, $conf)= @_;
	my $base= $conf->{base} ||= {};
	$base->{cache_root} ||= $e->config->{dir}{cache}
	                    || die q{ I want 'cache' dir. };
#	-w $base->{cache_root}
#	   || die q{ There is no permission in 'cache_root'. };
	$base->{namespace}          ||= 'sessions';
	$base->{cache_depth}        ||= 3;
	$base->{default_expires_in} ||= 60* 60;
	$class->next::method($e, $conf);
}

sub TIEHASH {
	my($ss)= shift->SUPER::TIEHASH(@_);
	$ss->cache( Cache::FileCache->new($ss->config->{base}) );
	$ss;
}

=head2 restore ( [SESSION_ID] )

The session data is acquired.

=cut
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my $data= $ss->cache->get($id) || return 0;
	$data->{session_session_id} ? $data: 0;
}

=head2 insert, update

The session data is preserved.

=cut
sub insert {
	my $ss= shift;
	$ss->cache->set($ss->session_id, $ss->{session});
	$ss;
}
*update= \&insert;

=head1 SEE ALSO

L<Cache::FileCache>,
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
