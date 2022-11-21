package Send::Email;

use strict;
use warnings;

use HTTP::API::Client;

my $key = "$ENV{SEND_GRID_KEY}";

sub email {
    my ( $class, %info ) = @_;
    my $from       = $info{from} or die "Missing send from";
    my $to         = $info{to}   or die "Missing send to";
    my $cc         = $info{cc};
    my $bcc        = $info{bcc};
    my $subject    = $info{subject};
    my $text       = $info{text};
    my $html       = $info{html};
    my @attachment = @{ $info{attachment} // [] };

    my %person = ();

    foreach my $where (qw(to cc bcc)) {
        my $emails = $info{$where} or next;
        die "Invalid Email"
          if ref $emails && !UNIVERSAL::isa( $emails, 'ARRAY' );
        $emails = [$emails] if !ref $emails;
        foreach my $email (@$emails) {
            my $list = $person{$where} //= [];
            push @$list, { email => $email };
        }
    }

    unshift @attachment,
      {
        type  => 'text/plain',
        value => $text,
      }
      if defined $text;

    unshift @attachment,
      {
        type  => 'text/html',
        value => $html,
      }
      if defined $html;

    my %message = (
        subject          => $subject,
        from             => { email => $from },
        personalizations => [ \%person ],
        content          => \@attachment
    );

    $DB::single = 2;

    my $resp = HTTP::API::Client->new(
        base_url     => URI->new('https://api.sendgrid.com/v3/mail'),
        content_type => 'application/json',
    )->post(
        '/send' => \%message,
        {
            Authorization => "Bearer $key"
        }
    );
}

1;
