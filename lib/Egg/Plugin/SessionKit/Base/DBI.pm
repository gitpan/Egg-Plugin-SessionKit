package Egg::Plugin::SessionKit::Base::DBI;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: DBI.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;
use warnings;
use base qw/Class::Accessor::Fast/;

our $VERSION = '0.04';

__PACKAGE__->mk_accessors( qw/dbh/ );

sub startup {
	my($class, $e, $conf)= @_;
	$e->isa('Egg::Plugin::DBI::CommitOK')
	  || Egg::Error->throw(q/Please build in Egg::Plugin::DBI::CommitOK./);
	$conf->{base}{dbname} ||= 'sessions';
	$conf->{base}{data_field_name} ||= 'session';
	$class->next::method($e, $conf);
}
sub TIEHASH {
	my($ss, $e, $conf)= @_;
	$ss= bless {}, $ss unless ref($ss);
	$ss->dbh($e->dbh);
	$ss->{dbname}= $conf->{base}{dbname};
	$ss->{data_field}= $conf->{base}{data_field_name};
	$ss->next::method($e, $conf);
}
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my $sesson;
	my $sth= $ss->dbh->prepare
	  (qq{ SELECT $ss->{data_field} FROM $ss->{dbname} WHERE id = ? });
	$sth->execute($id);
	$sth->bind_columns(\$sesson);
	$sth->fetch; $sth->finish;
	$sesson ? $ss->store_decode(\$sesson): 0;
}
sub insert {
	my($ss)= @_;
	my $sth= $ss->dbh->prepare
	  (qq{ INSERT INTO $ss->{dbname} (id, $ss->{data_field}) VALUES (?, ?) });
	$sth->execute($ss->session_id, $ss->store_encode($ss->{params}));
	$sth->finish;
	$ss;
}
sub update {
	my($ss)= @_;
	my $sth= $ss->dbh->prepare
	  (qq{ UPDATE $ss->{dbname} SET $ss->{data_field} = ? WHERE id = ? });
	$sth->execute($ss->store_encode($ss->{params}), $ss->session_id);
	$sth->finish;
	$ss;
}
sub commit_ok {
	shift->e->commit_ok(@_);
}
sub close {
	my($ss)= @_;
	$ss->rollback(1) if $ss->e->rollback_ok;
	$ss->next::method;
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Base::DBI - DBI module for SessonKit plugin.

=head1 SYNOPSIS

  use Egg qw/SessionKit DBI::CommitOK/;

Configuration.

  plugin_session=> {
    base=> {
      name            => 'DBI',
      dbname          => 'sesson_data',
      data_field_name => 'a_session',
      },
    store=> { name=> 'Base64' },
    },

=head1 DESCRIPTION

The data base steering wheel being offered by Egg::Plugin::DBI::CommitOK is used.

Please prepare the table for the following sessions.

  CREATE TABLE sessions (
    id        char(32)   primary key,
    lastmod   timestamp,
    a_session text
    );

It might be good for the value of lastmod to set and to renew the trigger.

DBI::CommitOK must be evaluated from SessionKit later when you describe the plugin in Egg.

  use Egg qw/
    SessionKit
    DBI::CommitOK
    /;

When close is done, the transaction doesn't do $e->commit_ok if it is effective
 and $e->rollback_ok true.

=over 4

=item close, commit_ok, insert, restore, startup, update,

These methods are called from the base module.

=back

=head1 CONFIGURATION

plugin_session->{base} is a setting of this module.

=head2 name

Please give to me as 'B<DBI>' if you use this module.

=head2 dbname

Please specify the table of the session.

B<Default is 'sessions'>

=head2 data_field_name

Field name where session data is preserved.

B<Default is 'session'>

Only place field today is customizable.

=head1 SEE ALSO

L<Egg::Model::DBI>
L<Egg::Plugin::DBI::CommitOK>
L<Egg::SessionKit>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut
