# botflood.pl -- irssi -- akill last x joins to channel

use Irssi;
use strict;

use vars qw($VERSION %IRSSI);
$VERSION = "1.0";
%IRSSI = (
        authors         => "David Shaw",
        contact         => 'dave.shaw@gmail.com',
        name            => "Botflood Killer",
        description     => "/botflood n -- Akills the last n users to join channel",
        license         => "FreeBSD License",
        changed         => "Thu Jul 14 2011"
);

my %buffer;

sub msg_join {
	my ($server, $channame, $nick, $host) = @_;
	my $key = $server->{tag} . $channame;
	$host =~ s/(.*)\@/\*\@/;
	if(exists $buffer{ $key }) {
		if(@{$buffer{ $key }} < 25) {
			push @{ $buffer{ $key }}, $host;
		}
		else {
			shift @{ $buffer{ $key }};
			push @{ $buffer{ $key }}, $host;
		}
	}
	else {
		push @{ $buffer{ $key }}, $host;
	}
}

sub botflood {
	my ($args, $server, $chan) = @_;
        unless ($chan && $chan->{type} eq "CHANNEL") {
                Irssi::print("%R>>%n no active channel");
                return;
        }
	my $channame = $chan->{name};
	my $key = $server->{tag} . $channame;
	#Irssi::print("Using key " . $key);

	if($args =~ /[0-9]+/) {
		for (my $i = 0; $i < $args; $i++) {
			my $size = @{$buffer{$key}};
			if($size) {
				$server->send_raw("PRIVMSG OperServ :akill add ".pop(@{$buffer{$key}})." flooder killed by botflood.pl");
				sleep 1;
			}
		}
	}
	else {
		foreach(@{$buffer{$key}}) {
			$server->send_raw("PRIVMSG OperServ :akill ".$_." flooder killed by botflood.pl");
			sleep 1;
		}
		@{$buffer{$key}} = ();
	}
}


Irssi::signal_add("message join", "msg_join");
Irssi::command_bind('botflood', 'botflood');