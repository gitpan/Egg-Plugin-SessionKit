package Egg::Plugin::SessionKit::Base::DBI;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: DBI.pm 159 2007-05-24 08:38:09Z lushe $
#
use strict;
use warnings;
use Time::Piece::MySQL;

our $VERSION = '2.01';

=head1 NAME

Egg::Plugin::SessionKit::DBI - Egg::Model::DBI for session.

=head1 SYNOPSIS

  use Egg qw/ SessionKit DBI::Transaction /;
  
  __PACKAGE__->mk_eggstartup(
    .......
    ...
    MODEL => [ [ DBI => { ... } ] ],
    
    plugin_session => {
      base => {
        name       => 'DBI',
        dbname     => 'sessions',
        data_field => 'a_session',
        time_field => 'lastmod',
        },
      .......
      ...
      },
    );

=head1 DESCRIPTION

The session by L<Egg::Model::DBI> is supported.

It is necessary to load L<Egg::Plugin::DBI::Transaction>.

Please make the table for the following sessions for the data base used.

  CREATE TABLE sessions (
    id        char(32)   primary key,
    lastmod   timestamp,
    a_session text
    );

* It is not forgotten to set an appropriate authority.

* Please set L<Egg::Plugin::SessionKit::Store::Base64> to the Store module.

* The function to clear the data not used is not included.
 Separately, it is necessary to delete it with cron etc. regularly.

=head1 CONFIGRATION

=head2 dbname

Name of table for session used.

Default is 'sessions'.

=head2 data_field

Name of column that stores session data.

Default is 'a_session'.

=head2 time_field

Name of column that stores updated day and hour.

Default is 'lastmod'.

=cut

__PACKAGE__->mk_accessors(qw/ dbh dbname datafield timefield /);

=head1 METHODS

=head2 startup

The setting is checked.

=cut
sub startup {
	my($class, $e, $conf)= @_;
	$e->isa('Egg::Plugin::DBI::Transaction')
	   || die q{ Please build in Egg::Plugin::DBI::Transaction. };
	my $base= $conf->{base} ||= {};
	$base->{dbname}     ||= $base->{db_name} ||= 'sessions';
	$base->{data_field} ||= 'a_session';
	$base->{time_field} ||= 'lastmod',
	$class->next::method($e, $conf);
}

sub TIEHASH {
	my($ss)= shift->SUPER::TIEHASH(@_);
	my $base= $ss->config->{base};
	$ss->dbh($ss->e->dbh);
	$ss->dbname($base->{dbname});
	$ss->datafield($base->{data_field});
	$ss->timefield($base->{time_field});
	$ss;
}

=head2 restore ( [SESSION_ID] )

The session data is acquired.

=cut
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my($dbname, $datafield)= ($ss->dbname, $ss->datafield);
	my $sesson;
	my $sth= $ss->dbh->prepare
	         (qq{ SELECT $datafield FROM $dbname WHERE id = ? });
	$sth->execute($id);
	$sth->bind_columns(\$sesson);
	$sth->fetch; $sth->finish;
	$sesson ? $ss->store_decode(\$sesson): 0;
}

=head2 insert

New session data is added.

=cut
sub insert {
	my($ss)= @_;
	my($dbname, $datafield, $timefield)=
	  ($ss->dbname, $ss->datafield, $ss->timefield);
	$ss->dbh->do(
	  qq{ INSERT INTO $dbname (id, $datafield, $timefield) VALUES (?, ?, ?) },
	  undef, $ss->session_id, $ss->store_encode($ss->{session}),
	         localtime(time)->mysql_datetime,
	  );
}

=head2 update

Existing session data is updated.

=cut
sub update {
	my($ss)= @_;
	my($dbname, $datafield, $timefield)=
	  ($ss->dbname, $ss->datafield, $ss->timefield);
	$ss->dbh->do(
	  qq{ UPDATE $dbname SET $datafield = ?, $timefield = ? WHERE id = ? },
	  undef, $ss->store_encode($ss->{session}),
	         localtime(time)->mysql_datetime, $ss->session_id,
	  );
}

=head2 commit_ok

Accessor to $e->commit_ok.

=cut
sub commit_ok {
	shift->e->commit_ok(@_);
}

=head2 close

Rollback is set if there are signs where some errors occurred before shutting
the session.

=cut
sub close {
	my($ss)= @_;
	$ss->rollback(1) if $ss->e->rollback_ok;
	$ss->next::method;
}

=head1 SEE ALSO

L<Egg::Model::DBI>,
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
