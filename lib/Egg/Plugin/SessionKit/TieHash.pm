package Egg::Plugin::SessionKit::TieHash;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: TieHash.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;
use base qw/Class::Accessor::Fast/;

our $VERSION= 0.02;

__PACKAGE__->mk_accessors( qw/e config new_entry update_ok rollback/ );

sub startup { @_ }

sub TIEHASH {
	my $ss= shift;
	my $e = shift || return 0;
	$ss= bless {}, $ss unless ref($ss);
	$ss->{e}= $e;
	$ss->{params} ||= {};
	$ss->{new_entry}= $ss->{update_ok}= $ss->{rollback}= 0;
	$ss;
}
sub FETCH {
	$_[0]->{params}{$_[1]} || "";
}
sub STORE {
	my($ss, $key, $value)= @_;
	$ss->update_ok(1) unless $ss->update_ok;
	$ss->{params}{$key}= $value;
}
sub DELETE {
	my($ss, $key)= @_;
	$ss->update_ok(1) unless $ss->update_ok;
	delete($ss->{params}{$key});
}
sub CLEAR {
	my($ss)= @_;
	$ss->update_ok(1) unless $ss->update_ok;
	$ss->{params}= {};
}
sub EXISTS {
	my($ss, $key)= @_;
	exists($ss->{params}{$key});
}
sub FIRSTKEY {
	my($ss)= @_;
	my $reset= keys %{$ss->{params}};
	each %{$ss->{params}};
}
sub NEXTKEY {
	each %{$_[0]->{params}};
}
sub DESTROY {
	$_[0]->close;
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::TieHash - TIE HASH base class for session.

=head1 SYNOPSIS

 use base qw/Egg::Plugin::SessionKit::TieHash/;
 
 sub TIEHASH {
   my $self= shift->SUPER::TIEHASH(@_);
   .... ban, ban, ban.
   $self
 }

=head1 DESCRIPTION

The Egg object is always necessary for the argument.

  sub TIEHASH {
    my($class, $e)= @_;
    $class->SUPER::TIEHASH($e);
  }

config, new_entry, update_ok, rollback

It has the above-mentioned accessor.

If some changes are done as the value is substituted, 'update_ok' becomes ture.

  # The first stage is false.
  tied(%{$e->session})->update_ok < 1;
  
  $e->session->{hoge}= 1;
  
  # When the value is put, it is ture.
  tied(%{$e->session})->update_ok > 0;

=head1 METHODS

=over 4

=item startup

The place today is a method of the dummy. Nothing is done.

=back

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
