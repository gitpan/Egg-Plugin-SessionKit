package Egg::Plugin::SessionKit;
#
# Copyright (C) 2007 Bee Flag, Corp, All Rights Reserved.
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: SessionKit.pm 69 2007-03-26 02:15:26Z lushe $
#
use strict;
use warnings;
use UNIVERSAL::require;

our $VERSION = '0.08';

*sss= \&session;

sub setup {
	my($e)= @_;
	my $conf = $e->config->{plugin_session} ||= {};
	my $tconf= $conf->{ticket} ||= {};
	$tconf->{param_name} ||= 'ticket';
	my $tclass=
	  'Egg::Plugin::SessionKit::Issue::'. ($tconf->{issue} || 'MD5');
	$tclass->require;
	tied(%{$e->global})->global_overwrite(
	  EGG_SESSION_TICKET_ISSUE_CODE=>
	    sub { $tclass->issue_id($tconf->{length} || 32) }
	  );
	my $handler= $e->global->{EGG_SESSION_HANDLER} ||= __PACKAGE__.'::handler';
	$handler->startup($e);
	$e->next::method;
}
sub session {
	$_[0]->{session} ||= do {
		my $e= shift;
		my $handler= $e->global->{EGG_SESSION_HANDLER};
		my %session;
		tie %session, $handler, $e, $e->config->{plugin_session};
		\%session;
	  };
}
sub ticket_id {
	my $e= shift;
	if (@_) {
		$e->session->{session_ticket_id}=
		  $_[0] ? $e->global->{EGG_SESSION_TICKET_ISSUE_CODE}->(): 0;
	}
	$e->session->{session_ticket_id};
}
sub ticket_check {
	my $e= shift;
	my $ticket= shift
	  || $e->request->params->{$e->config->{plugin_session}{ticket}{param_name}}
	  || return do { $e->debug_out("# - ticket is undefined."); 0 };
	return do { $e->debug_out("# - session_ticket is undefined."); 0 }
	  unless my $id= $e->session->{session_ticket_id};
	return 1 if $id eq $ticket;
	$e->debug_out("# - ticket is unmatched. ($ticket = $id)");
	return 0;
}
sub finalize {
	my($e)= @_;
	if ($e->{session}) {
		untie %{$e->{session}};
		$e->{session}= undef;
	}
	$e->next::method;
}

package Egg::Plugin::SessionKit::handler;
use strict;
use warnings;
use UNIVERSAL::require;
use Class::C3;

sub startup {
	my($class, $e)= @_;
	return @_ if $e->global->{EGG_SESSION_STARTUP};
	$e->global->{EGG_SESSION_STARTUP}= 1;
	no strict 'refs';  ## no critic
	no warnings 'redefine';

	my $conf= $e->config->{plugin_session} ||= {};
	@{__PACKAGE__.'::ISA'}= 'Egg::Plugin::SessionKit::base';
	$e->debug_out("#=== Composition of SessionKit =========");
	my @requires;
	for my $a (
	  [qw/base  FileCache/],
	  [qw/store Plain/ ],
	  [qw/bind  Cookie/],
	  [qw/issue MD5/   ],
	  ) {
		my $type= ucfirst($a->[0]);
		my $cf  = $conf->{$a->[0]} ||= {};
		my $name= $cf->{name} ||= $a->[1];
		my $pkg = "Egg::Plugin::SessionKit::$type\::$name";
		unshift @{__PACKAGE__.'::ISA'}, $pkg;
		unshift @requires, $pkg;
		$e->debug_out("# + $pkg");
	}
	$_->require or Egg::Error->throw($@) for @requires;
	$e->debug_out("#=======================================");

	my $agent= exists($conf->{verifi_agent}) ? $conf->{verifi_agent}: 0;
	*{__PACKAGE__.'::agent_check'}= $agent ? do {
		$e->debug_out("# + session verifi_agent: ON.");
		sub {
			my $ss= shift;
			my $ua= shift || return 0;
			$ss->e->request->agent eq $ua ? 1: 0;
		  };
	  }: do {
		$e->debug_out("# + session verifi_agent: OFF.");
		sub { 1 };
	  };

	my $level= exists
	  ($conf->{ipaddr_check_level}) ? $conf->{ipaddr_check_level}: 1;
	*{__PACKAGE__.'::ipaddr_check'}= $level ? do {
		$level=~/^(?:1|C)/i ? do {
			$e->debug_out("# + session ipaddr check: C class.");
			sub {
				my $ss= shift;
				my $addr= shift || return 1;
				my($a1, $a2, $a3)= $addr=~/^(\d+)\.(\d+)\.(\d+)/;
				$ss->e->request->address=~/^$a1\.$a2\.$a3\.\d+$/ ? 1: 0;
			  };
		  }: do {
			$e->debug_out("# + session ipaddr check: Absolute.");
			sub {
				my $ss= shift;
				my $addr= shift || return 0;
				$ss->e->request->address eq $addr ? 1: 0;
			  };
		  };
	  }: do {
		$e->debug_out("# + session ipaddr check: None.");
		sub { 1 };
	  };

	for my $accesssor (qw/session_id user_agent
	  remote_addr create_time access_time_old access_time_now/) {
		*{"Egg::Plugin::SessionKit::base::$accesssor"}=
		  sub { $_[0]->{params}{"session_$accesssor"} || 0 };
	}

	$class->SUPER::startup($e, $conf);
}

package Egg::Plugin::SessionKit::base;
use strict;
use warnings;
use base qw/Egg::Plugin::SessionKit::TieHash/;

sub startup { @_ }
sub commit_ok { }

sub TIEHASH {
	my($class, $e)= @_;
	my $ss= $class->SUPER::TIEHASH($e);
	$ss->{config}= $e->config->{plugin_session};
	$ss->{param_name}= $ss->{config}->{bind_param_name} || '';
	$ss->{id_length} = $ss->{config}->{session_id_length} || 0;
	$ss->{params}= $ss->get_session_data;
	$ss;
}
sub get_session_data {
	my($ss)= @_;
	my $id= $ss->get_session_id();
	my $data= {};
	unless ($ss->new_entry) {
		$ss->e->debug_out("# + session restore: $id");
		$data= $ss->restore($id) || do { $id= $ss->create_session_id; {} };
	}
	$ss->normalize($data, $id);
}
sub get_session_id {
	my $ss= shift;
	if (my $id= $ss->get_bind_data($ss->{param_name})) {
		return ($ss->issue_check_id($id, $ss->{id_length})
		     || $ss->create_session_id);
	} else {
		return  $ss->create_session_id;
	}
}
sub create_session_id {
	my($ss)= @_;
	my $id= $ss->issue_id
	  || Egg::Error->throw(q/e->issue_id doesn't function normally./);
	$ss->e->debug_out("# + session new_entry : $id");
	$ss->new_entry(1);
	return $id;
}
sub normalize {
	my($ss, $data, $id)= @_;
	if (my $agent= $data->{session_user_agent})
	  { $data= {} unless $ss->agent_check($agent) }
	if (my $addr= $data->{session_remote_addr})
	  { $data= {} unless $ss->ipaddr_check($addr) }
	$data->{session_user_agent}   ||= $ss->e->request->agent;
	$data->{session_remote_addr}  ||= $ss->e->request->address;
	$data->{session_session_id}   ||= $id;
	$data->{session_create_time}  ||= time;
	$data->{session_access_time_old}= $data->{session_access_time_now} || 0;
	$data->{session_access_time_now}= time;
	$data;
}
sub change {
	my($ss)= @_;
	$ss->{params}{session_id}= $ss->create_session_id;
	$ss->{params}{create_time} ||= time;
	$ss->update_ok(1);
	$ss;
}
sub clear {
	my($ss)= @_;
	$ss->{params}= $ss->normalize({}, $ss->create_session_id);
	$ss->update_ok(1);
	$ss;
}
sub output_session_id {
	my $ss= shift;
	my $id= shift || $ss->session_id;
	$ss->set_bind_data($ss->{param_name}=> $id, @_);
}
sub close {
	my($ss)= @_;
	if ($ss->e && $ss->update_ok && ! $ss->rollback) {
		if ($ss->new_entry) {
			$ss->e->debug_out
			  ("# + session insert: ". $ss->session_id) if $ss->e;
			$ss->insert;
			$ss->output_session_id;
		} else {
			$ss->e->debug_out
			  ("# + session update: ". $ss->session_id) if $ss->e;
			$ss->update;
		}
		$ss->commit_ok(1);
	}
	$ss;
}

1;

__END__

=head1 NAME

Egg::Plugin::SessionKit - Session plugin for Egg.

=head1 SYNOPSIS

  package [MYPROJECT];
  use strict;
  use Egg qw/SessionKit/;

Configuration.

  plugin_session=> {
    bind_param_name   => 'ss';
    session_id_length => 32,
    base=> {
      name => 'FileCache',
      cache_root=> ...
      ... Other Cache::FileCache options.
      },
    bind=> {
      name=> 'Cookie',
      },
    store=> {
      name=> 'Plain',
      },
    issue=> {
      name=> 'MD5',
      },
    ticket=> {
      issue => 'MD5',
      length=> 32,
      },
    },

Example of code.

  # The value is preserved in session.
  $e->session->{any_data}= 'banban';
  
  # Refer to session id.
  print "sesson_id : ". tied(%{$e->session})->session_id;
  
  # Session id is changed. Data is succeeded.
  tied(%{$e->session})->change;
  
  # It initializes in the session data.
  tied(%{$e->session})->clear;
  
  # The ticket is temporarily issued.
  my $ticket= $e->ticket_id(1);
  
  # Tickets that have been issued are compared.
  if (my $ticket= $e->ticket_check) {
  	print "OK";
  } else {
  	print "NG";
  }

=head1 CONFIGURATION

=head2 bind_param_name

Parameter name that uses session ID when client and receiving and passing it.

B<Default is 'ss'.>

=head2 session_id_length

Length of issued session id.

B<Default is '32'.>

=head2 base

Please specify the module that controls basic operation of the session by 'name' field.
The package name is supplemented with 'Egg::Plugin::SessionKit::Base'.

B<Default is 'FileCache'.>

Additionally, it becomes an option to pass to the module.

=head2 bind

The module related to the delivery processing of session id is specified in 'name' field.
The package name is supplemented with 'Egg::Plugin::SessionKit::Bind'.

B<Default is 'Cookie'.>

Additionally, it becomes an option to pass to the module.

=head2 store

The module concerning the preservation form of the session data is specified in 'Name' field.
The package name is supplemented with 'Egg::Plugin::SessionKit::Store'.

B<Default is 'Plain'.>

Additionally, it becomes an option to pass to the module.

Please note compatibility with the module specified for 'base'.

=head2 issue

The module concerning session id issue is specified in 'Name' field.
The package name is supplemented with 'Egg::Plugin::SessionKit::Issue'.

B<Default is 'MD5'.>

Additionally, it becomes an option to pass to the module.

=head2 ticket

It is temporarily a setting concerning the ticket.

=over 4

=item * issue

Please specify the module that issues ticket id.
Thing without fail to specify module that subordinate of 'Egg::Plugin::SessionKit::Issue' has.

B<Default is 'MD5'.>

=item * length

The length of ticket ID is set.

B<Default is '32'.>

=item * param_name

Form name when ticket is handed over.

B<Default is 'ticket'.>

=back

=head1 METHODS

=head2 $e->session  or $e->sss;

The HASH reference of the session is obtained.

Please use tied if you want the session object.

 my $session_oject= tied(%{$e->session});

=head2 $session_oject->session_id;

Present session ID is returned.

=head2 $session_oject->user_agent

$ENV{HTTP_USER_AGENT} preserved in the session is returned.

=head2 $session_oject->remote_addr

IP address preserved in the session is returned.

=head2 $session_oject->create_time

The time value when the session under the access is made is returned.

=head2 $session_oject->access_time_now

time value now at the time of preserved it in the session is returned.

=head2 $session_oject->access_time_old

The time value when it was accessed before is returned.

=head2 $session_oject->change

Only session id is changed. Other data is maintained.
And, create_time becomes new, too.

=head2 $session_oject->clear

All present sessions are abandoned and it renews it.

=head2 $e->ticket_id([Boolean]);

1 The ticket is temporarily issued when giving it and is preserved in the session.
0 Invalidates the ticket preserved in the session when giving it.

  my $ticket= $e->ticket_id(1);

=head2 $e->ticket_check([TICKET_ID]);

The ticket preserved in the session and the given ticket are compared.
When the ticket is corresponding, the given ticket is returned.

When [TICKET_ID] is omitted, the value is picked up from $e->request->param.

  if ($e->ticket_check) {
    .... processing is executed.
  } else {
    print "Processing is completed.";
  }

=head2 finalize

It is a method that calls from Egg::Engine. It commits it if necessary.

=head2 setup

It is a method for the start preparation that is called from the controller of 
the project. * Do not call it from the application.

=head1 SEE ALSO

L<Egg::Plugin::SessionKit::TieHash>,
L<Egg::Plugin::SessionKit::Base::FileCache>,
L<Egg::Plugin::SessionKit::Base::DBIC>,
L<Egg::Plugin::SessionKit::Base::DBI>,
L<Egg::Plugin::SessionKit::Bind::Cookie>,
L<Egg::Plugin::SessionKit::Store::Plain>,
L<Egg::Plugin::SessionKit::Store::Base64>,
L<Egg::Plugin::SessionKit::Issue::MD5>,
L<Egg::Plugin::SessionKit::Issue::UniqueID>,
L<Egg::Release>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright (C) 2007 by Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

