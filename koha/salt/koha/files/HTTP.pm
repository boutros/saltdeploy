package SMS::Send::NO::HTTP;

use warnings;
use strict;
use Carp;
use version; our $VERSION = qv('0.0.2');

use LWP::UserAgent;
use URI::Escape;
use HTTP::Request::Common qw(POST);
use base 'SMS::Send::Driver';

our $URL     = 'https://tjenester.oslo.kommune.no/intern/mailsms/SendSms'; # for now, hardcoded url
our $AGENT   = 'SMS-Send-HTTP/' . $VERSION;
our $METHOD  = 'POST';
our $TIMEOUT = 3;

#####################################################################
# Constructor

sub new {
  my $class = shift;
  my %args = @_;

  # Create the object
  # TODO: remove hardcoding of url param
  my $url   = $args{'_url'}     || $URL; #Carp::croak("Need _url param: The URL to the SMS API");
  my $agent = $args{'_agent'}   || $AGENT;
  my $timeout = $args{'_timeout'} || $TIMEOUT;
  my $self = bless {
    'url'      => $url,
    'agent'    => $agent,
    'timeout'  => $timeout
  }, $class;

  return $self;
}

sub send_sms {
    my $self   = shift;
    my %params = @_;
 
  # cleanup cell number
  $params{to} =~ s/[^0-9]//g; # remove non-digits

  # validate
  croak q{'to' must contain between 8 and 14 digits}
      if length $params{to} < 8 or length $params{to} > 14;
  croak q{'_from' and 'text' combined must not be more than 159 characters} 
      if length( $params{text} ) > 159;
  
  # Send
  my $ua = new LWP::UserAgent;

  my $req = (
     POST $self->{url},
     Content_Type  => 'application/x-www-form-urlencoded',
     Content       => [ 'to' => $params{to},
                        'text' => $params{text} ]
  );
  my $res = $ua->request($req);

  if (defined $res and $res->is_success) {
    return {
      res => $res->content
    };
  } else {
    return { error => $res->as_string };
  }
}

1; 

__END__

=head1 NAME

SMS::Send::NO::HTTP - Generic SMS::Send driver for a Norwegian HTTP/HTTPS API

=head1 VERSION

This document describes SMS::Send::NO::HTTP version $VERSION

=head1 SYNOPSIS

    use SMS::Send;
    my $sender = SMS::Send->new('NO::HTTP');

    $sender->send_sms(
      '_from' => 'Test Testesen', # prepended to 'text' seperated by '/', I dunno; that what their site does :)
      'to'    => '012345678', # mobile number
      'text'  => 'some text'
    ) or _handle_sms_error( $@ );  
  
=head1 DESCRIPTION

Sends an SMS::Send message to a generic HTTP/HTTPS API via the L<SMS::Send> driver.

Uses 'to' and 'text' as per L<SMS::Send> and additionally uses '_from' to prepend who its from to 'text'.


=head1 INTERFACE 

=head2 new

No extra args, just
  SMS::Send->new('NO::HTTP');

=head2 send_sms

If send_sms() returns true then tmobile said it was sent.

If send_sms() returns false then $@ is set to a hashref of the following info:

  {
    'args'       => {}, # arguments to send_sms()
    'caller'     => [], # caller() info
    'url'        => '', # tmobile URL involved
    'content'    => '', # content POSTed to the url above
    'is_success' => '', # was HTTP POST successful or not (1 or 0)
    'as_string'  => '', # HTTP POST response as a string
  }

=head1 DIAGNOSTICS

=over

=item C<< 'to' must contain ten digits >>

The value passed to 'to' does not have ten digits.

=item C<< '_from' and 'text' combined must not be more than 159 characters >>

The length of characters in '_from' and 'text' put together are too long.

The limit is 160 but the two fields are seperated by a '/' which takes up one character so you have 159 to work with.

=back

=head1 CONFIGURATION AND ENVIRONMENT
  
SMS::Send::NO::HTTP requires no configuration files or environment variables.


=head1 DEPENDENCIES

L<LWP::UserAgent>, L<URI::Escape>, L<SMS::Send::Driver>, L<HTTP::Request::Common>

=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<benjamin.rokseth@kul.oslo.kommune.no>

=head1 AUTHOR

'Benjamin Rokseth C<< <http://benjamin.rokseth@kul.oslo.kommune.no> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2014, Benjamin Rokseth C<< <http://benjamin.rokseth@kul.oslo.kommune.no> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
