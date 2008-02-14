package Egg::Model::Session::Plugin::Ticket;
#
# Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>
#
# $Id: Ticket.pm 256 2008-02-14 21:07:38Z lushe $
#
use strict;
use warnings;
use Carp qw/ croak /;
use Digest::SHA1 qw/ sha1_hex /;

our $VERSION= '0.01';

sub _setup {
	my($class, $e)= @_;
	$class->config->{ticket_length} ||= 32;
	$class->next::method($e);
}
sub ticket {
	my $self  = shift;
	my $name  = shift || 'default';
	my $ticket= $self->data->{_session_ticket} ||= {};
	return ($ticket->{$name} || "") unless defined($_[0]));
	$self->is_update(1);
	unless ($_[0]) {
		my $i= $ticket->{$name} || return 0;
		$self->e->debug_out("# + !! Ticket '$name' is remove. [$i]");
		return delete($ticket->{$name}) ;
	}
	my $id= substr(
	  sha1_hex( time. $$. rand(1000). {} ), 0, $self->config->{ticket_length},
	  );
	$ticket->{$name}= [ $id , time ];
	$self->e->debug_out("# + Ticket '$name' is create. [$id]");
	$id;
}
sub ticket_check {
	my $self  = shift;
	my $name  = shift || 'default';
	my $value = shift || croak q{I want ticket value.};
	my $ticket= $self->data->{_session_ticket} || return -2;
	unless ($ticket->{$name}) {
		$self->e->debug_out("# + Ticket '$name' is unset.");
		return -1;
	}
	return $ticket->{$name}[0] eq $value
	   ? do { $self->e->debug_out("# + Ticket '$name' is match."); 1 }
	   : do { $self->e->debug_out("# + !! Ticket '$name' is unmatch."); 0 };
}
sub ticket_clear {
	my $self   = shift;
	my $name   = shift || 0;
	my $session= $self->data;
	if ($name) {
		if ($session->{_session_ticket}{$name}) {
			$self->e->debug_out("# + Ticket '$name' is clear.");
			delete($session->{_session_ticket}{$name});
			$self->is_update(1);
		}
	} else {
		if ($session->{_session_ticket}) {
			$self->e->debug_out("# + !! Ticket '$name' is all clear.");
			$self->DELETE('_session_ticket');
		}
	}
	$e;
}
sub ticket_purge {
	my $self   = shift;
	my $lapse  = shift || 60* 10;   # default is 10 minute.
	my $session= $self->data;
	my $ticket = $session->{_session_ticket} || return 0;
	$lapse= time- $lapse;
	my $count;
	while (my($name, $v)= each %$ticket) {
		next if $v->[1] > $lapse;
		delete $ticket->{$name};
		++$count;
	}
	if ($count) {
		$self->is_update(1);
		$self->e->debug_out("# + !! $count tickets are deleted.");
	}
	$self->DELETE('_session_ticket') unless %$ticket;
	$e;
}

1;

__END__

=head1 NAME

Egg::Model::Session::Plugin::Ticket - Plugin for session to handle ticket temporarily.

=head1 SYNOPSIS

  package MyApp::Model::Sesion::MySession;
  
  __PACKAGE__->startup(
   Plugin::Ticket
   .....
   );

=head1 DESCRIPTION

It is a plugin for the session to handle the ticket temporarily to use it from 
the input form etc.

The use of temporarily confirming the agreement of the ticket sent together when
 the ticket is temporarily issued when the input form is displayed, and it is 
transmitted from the form is assumed.

  1... The ticket is temporarily issued, and the ticket ID is buried under the input form etc.
  2... When the client transmits the input form, the ticket is temporarily sent to the application.
  3... When the ticket is not temporarily corresponding it, the application plays it.

To use it, 'Plugin::Ticket' is added to 'startup'.

Then, the method of this plugin is added to the session object.

The character length of ticket ID is temporarily decided to 'ticket_length' by 
the configuration.

  __PACKAGE__->config (
    ticket_length => 32,
    );

L<Digest::SHA1> is used for ticket ID generation.

=head1 METHODS

=head2 ticket ([ID_KEY], [FLAG_BOOL])

The ticket is issued temporarily new and invalidated.

ID_KEY is a name of the issued key that temporarily preserves the ticket in the
session. 'default' is used at the unspecification.

FLAG_BOOL is temporarily issues the ticket or an existing flag whether to 
invalidate the ticket temporarily.

  # Receipt of session object.
  my $session= $e->model('session_name');
  
  # Temporary issue of ticket.
  my $ticket_id = $session->ticket( ticket_name => 1 );
  
  # The ticket is temporarily invalid.
  $session->ticket( ticket_name => 0 );

=head2 ticket_check ([ID_KEY], [TICKET_ID])

It confirms whether the ticket is temporarily corresponding to the existing one
and the result is returned.

ID_KEY is a name of the issued key that temporarily preserves the ticket in the 
session. 'default' is used at the unspecification.

TICKET_ID is already issued temporarily ID of the ticket. When TICKET_ID is 
unspecification, the exception is generated.

The result returns by the following numerical values.

  -2 = When the data confidence to become the origin of the ticket preservation is not found temporary.
  -1 = When data concerning ID_KEY is not preserved.
   0 = When not agreeing.
   1 = When agreeing.


  if ( 0 < $session->ticket_check( ticket_name => $e->request->param('ticket_name') ) ) {
     ... The ticket is a code when agreeing.
  } else {
     ... The ticket is a code when not agreeing.
  }

=head2 ticket_clear ([ID_KEY])

The ticket has been temporarily deleted of the issue.

Only the relating key data annuls all the preserved data at the unspecification
 when ID_KEY is specified.

  # The delete key is specified.
  $session->ticket_clear('ticket_name');
  
  # The ticket all is temporarily deleted.
  $session->ticket_clear;

The method here makes 'is_update' effective though a thing similar only as for 
sending of the annulment of ID_KEY specifying it the flag to 'ticket' method 
can be done.
Therefore, data might actually remain in the session only by 'ticket' method.
Please use the method here when you want temporarily to invalidate the ticket 
surely that.

  # If it is a situation in which the session is not preserved by another, the 
  # ticket is not temporarily deleted from real data because 'is_update' is not
  # made effective.
  $session->ticket( ticket_name => 0 );

=head2 ticket_purge ([TIME_VALUE])

TIME_VALUE is deleted and passage annuls all tickets temporarily.

  # All the passage of ten minutes is deleted.
  $session->ticket_purge( 10* 60 );
  
  # All the passage of 1 hour is deleted.
  $session->ticket_purge( 1* 60* 60 );
  
  # All the passage of a 1 day is deleted.
  $session->ticket_purge( 1* 24* 60* 60 );

=head1 SEE ALSO

L<Egg::Release>,
L<Egg::Model::Session::Manager::TieHash>,
L<Digest::SHA1>,

=head1 AUTHOR

Masatoshi Mizuno E<lt>lusheE<64>cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2008 Bee Flag, Corp. E<lt>L<http://egg.bomcity.com/>E<gt>, All Rights Reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.6 or,
at your option, any later version of Perl 5 you may have available.

=cut

