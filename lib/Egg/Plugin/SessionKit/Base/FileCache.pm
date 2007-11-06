package Egg::Plugin::SessionKit::Base::FileCache;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: FileCache.pm 214 2007-11-06 13:51:19Z lushe $
#
use strict;
use warnings;
use Cache::FileCache;

our $VERSION= '2.10';

=head1 NAME

Egg::Plugin::SessionKit::Base::FileCache - Cache::FileCache for Session.

=head1 SYNOPSIS

  use Egg qw/ SessionKit /;
  
  __PACKAGE__->egg_startup(
    .......
    ...
    plugin_session => {
      key_name => 'ss',
      component=> [
  
        [ 'Base::FileCache' => {
          cache_root  => '/path/to/cache',
          namespace   => 'sessions',
          cache_depth => 3,
          default_expires_in => (60* 60),
          } ],
  
        qw/ Bind::Cookie Store::Plain /,
  
        ],
      },
    );

=head1 DESCRIPTION

The session by L<Cache::FileCache> is supported.

=head1 CONFIGRATION

The setting becomes an option to pass everything to L<Cache::FileCache>.

Please refer to the document of L<Cache::FileCache>.

=head1 METHODS

=head2 startup

The setting is checked.

=head2 restore ( [SESSION_ID] )

The session data is acquired.

=head2 insert, update

The session data is preserved.

=head2 delete ( [SESSION_ID] )

Remove cache SESSION_ID.

=cut

sub startup {
	my($class, $e, $conf)= @_;
	my $cf= $conf->{base_filecache};
	$cf->{cache_root} ||= $e->config->{dir}{cache}
	                  || die q{ I want 'cache' dir. };
	$cf->{namespace}   ||= 'sessions';
	$cf->{cache_depth} ||= 3;
	$cf->{default_expires_in} ||= 60* 60;
	$class->mk_ro_accessors('cache');
	$class->next::method($e, $conf);
}
sub TIEHASH {
	my($ss)= shift->next::method(@_);
	$ss->attr->{cache}=
	   Cache::FileCache->new($ss->mod_conf->{base_filecache});
	$ss;
}
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my $data= $ss->cache->get($id) || return 0;
	$data->{session_id} ? $data: 0;
}
sub insert {
	my($ss)= @_;
	$ss->cache->set($ss->is_session_id, $ss->[0]);
	$ss;
}
sub delete {
	my $ss= shift;
	my $id= shift || return 0;
	$ss->cache->remove($id);
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
