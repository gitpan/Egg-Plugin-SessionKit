package Egg::Plugin::SessionKit::Issue::MD5;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: MD5.pm 266 2007-03-01 13:14:01Z lushe $
#
use strict;
use Digest::MD5;

our $VERSION= '0.02';

sub startup {
	my($class, $e, $conf)= @_;
	$conf->{issue}{id_length} ||= 32;
	$class->next::method($e, $conf);
}
sub issue_id {
	my $ss  = shift; rand(1000);
	my $leng= shift || $ss->config->{issue}{id_length};
	substr( Digest::MD5::md5_hex
	  ( Digest::MD5::md5_hex(time. {}. rand(1000). $$) ), 0, $leng );
}
sub issue_check_id {
	my $ss= shift;
	my $id= shift || return 0;
	my $leng= shift || $ss->config->{issue}{id_length};
	$id=~/^[a-f0-9]{$leng}$/ ? $id: 0;
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Issue::MD5 - Session id is issued by Digest::MD5.

=head1 SYNOPSIS

Configuration.

  plugin_session=> {
    issue=> {
      name=> 'MD5',
      },
    },

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
