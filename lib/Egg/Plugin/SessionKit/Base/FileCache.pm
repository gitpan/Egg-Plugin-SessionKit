package Egg::Plugin::SessionKit::Base::FileCache;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: FileCache.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;
use warnings;
use Cache::FileCache;
use base qw/Class::Accessor::Fast/;

our $VERSION= '0.05';

__PACKAGE__->mk_accessors( qw/cache/ );

*update= \&insert;

sub startup {
	my($class, $e, $conf)= @_;
	$conf->{base}{cache_root} ||= $e->config->{cache}
	  || Egg::Error->throw(q/I want 'cache' dir./);
	-w $conf->{base}{cache_root}
	  || Egg::Error->throw(q/There is no permission in 'cache_root'./);
	$conf->{base}{namespace} ||= 'sessions';
	$conf->{base}{cache_depth} ||= 3;
	$conf->{base}{default_expires_in} ||= 60* 60;
	$class->next::method($e, $conf);
}
sub TIEHASH {
	my($ss, $e, $conf)= @_;
	$ss= bless {}, $ss unless ref($ss);
	$ss->cache( Cache::FileCache->new($conf->{base}) );
	$ss->next::method($e, $conf);
}
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my $data= $ss->cache->get($id) || return 0;
	$data->{session_session_id} ? $data: 0;
}
sub insert {
	my $ss= shift;
	$ss->cache->set($ss->session_id, $ss->{params});
	$ss;
}

1;

=head1 NAME

Egg::Plugin::SessionKit::Base::FileCache - The session is operated by FileCache.

=head1 SYNOPSIS

Configuration.

  plugin_session=> {
    base=> {
      name=> 'FileCache',
      namespace  => 'session_space',
      cache_root => '/path/to/chache',
      cache_depth=> 3,
      default_expires_in=> (30* 60),
      ...
      },
    },

=head1 DESCRIPTION

The function to delete the preserved cash file is not provided.

Please give the script that Mentes it the cash file to me separately in the business 
mind by Clear and Purge of Cache::FileCache.

As for the setting of plugin_session->{base}, Cache::FileCache is passed as it is. 

Please see the document of Cache::FileCache of the setting in detail.

=over 4

=item insert, restore, startup, update,

These methods are called from the base module.

=back

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
