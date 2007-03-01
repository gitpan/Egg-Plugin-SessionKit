package Egg::Plugin::SessionKit::Base::DBIC;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: DBIC.pm 265 2007-03-01 13:12:09Z lushe $
#
use strict;
use warnings;

our $VERSION = '0.01';

my @context_fields=
qw{ _schema_name _model_name id_field data_field access_field };
my @config_fields=
qw{ _schema_name _model_name id_field_name data_field_name access_field_name };

sub startup {
	my($class, $e, $conf)= @_;
	$e->isa('Egg::Plugin::DBIC::Transaction') ||
	  Egg::Error->throw(qq{ Please build in plugin 'DBIC::Transaction'. });
	my $schema= lc($conf->{base}{schema_name})
	  || Egg::Error->throw(qq{ I want setup 'schema_name'. });
	my $source= lc($conf->{base}{source_name})
	  || Egg::Error->throw(qq{ I want setup 'schema_name'. });
	$e->is_model("$schema\:$source")
	  || Egg::Error->throw(qq{ '$schema\:$source' model is not found. });
	$conf->{base}{_schema_name} = "$schema";
	$conf->{base}{_model_name}  = "$schema\:$source";
	$conf->{base}{id_field_name} ||= 'id';
	$conf->{base}{data_field_name} ||= 'session';
	$conf->{base}{access_field_name} ||= 'access_date';
	$class->next::method($e, $conf);
}
sub TIEHASH {
	my($ss, $e, $conf)= @_;
	$ss= bless {}, $ss unless ref($ss);
	@{$ss}{@context_fields}= @{$conf->{base}}{@config_fields};
	$ss->next::method($e, $conf);
}
sub restore {
	my $ss= shift;
	my $id= shift || return 0;
	my $field = $ss->{data_field};
	$ss->{_session}= $ss->model->find($id) || return 0;
	my $data= $ss->{_session}->$field;
	$ss->store_decode( \$data );
}
sub insert {
	my($ss)= @_;
	undef($ss->{_session}) if $ss->{_session};
	$ss->model->create({
	  $ss->{id_field}    => $ss->session_id,
	  $ss->{data_field}  => $ss->store_encode($ss->{params}),
	  $ss->{access_field}=> $ss->__now_date,
	  });
}
sub update {
	my($ss)= @_;
	my($access_field, $data_field)= @{$ss}{qw/ access_field data_field/};
	$ss->{_session}->$access_field( $ss->__now_date );
	$ss->{_session}->$data_field( $ss->store_encode($ss->{params}) );
	$ss->{_session}->update;
}
sub commit_ok {
	my($ss)= @_;
	my $commit_ok= "$ss->{_schema_name}_commit_ok";
	$ss->e->$commit_ok(@_);
}
sub close {
	my($ss)= @_;
	my $rollback_ok= "$ss->{_schema_name}_commit_ok";
	$ss->rollback(1) if $ss->e->$rollback_ok;
	$ss->next::method;
}
sub model {
	$_[0]->{__model} ||= $_[0]->e->model( $_[0]->{_model_name} );
}
sub __now_date {
	my @tm= localtime(time);
	$tm[5]+= 1900; ++$tm[4];
	sprintf "%04d-%02d-%02d %02d:%02d:%02d", reverse(@tm[0..5]);
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit::Base::DBIC - DBIx::Class for SessonKit plugin.

=head1 SYNOPSIS

  use Egg qw/SessionKit DBIC::Transaction/;

Configuration.

  plugin_session=> {
    base=> {
      name              => 'DBIC',
      schema_name       => 'MyApp',
      source_name       => 'Sessions',
      id_field_name     => 'id',
      data_field_name   => 'a_session',
      access_field_name => 'lastmod',
      },
    store=> { name=> 'Base64' },
    },

=head1 DESCRIPTION

Please prepare the table for the following sessions.

  CREATE TABLE sessions (
    id        char(32)   primary key,
    lastmod   timestamp,
    a_session text
    );

Please build in and use Egg::Plugin::DBIC::Transaction.

* AutoCommit が有効でも E::P::DBIC::Transaction を使用して下さい。
  E::P::DBIC::Transaction は AutoCommit の状態に応じた動作をします。

=head1 CONFIGURATION

plugin_session->{base} is a setting of this module.

=head2 name

Please give to me as 'B<DBIC>' if you use this module.

=head2 schema_name

Name of schema module that data table used belongs.

=head2 source_name

Name of module of data table.

=head2 id_field_name

Name of ID column.

=head2 access_field_name

Name of last updated date column.

=head2 data_field_name

Name of session data column.

=head1 SEE ALSO

L<Egg::Model::DBIC>,
L<Egg::Plugin::DBIC::Transaction>,
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

