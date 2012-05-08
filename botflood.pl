# botflood.pl -- irssi -- akill last x joins to channel

use Irssi;
use strict;

use vars qw($VERSION %IRSSI);
$VERSION = "1.0";
%IRSSI = (
        authors         => "David Shaw",
        contact         => 'dave.shaw@gmail.com',
        name            => "Botflood Killer",
        description     => "/botflood n -- akills the last n users to join channel",
        license         => "FreeBSD License",
        changed         => "Thu Jul 14 2011"
);

my %buffer;

sub msg_join {
	my ($server, $channame, $nick, $host) = @_;
	if($channame == "#2600") {
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
}

sub akill {
	my ($args, $server, $chan) = @_;
	if($args =~ / /) {
		$args =~ s/(.*) /$1/;
	}
	my ($Nick) = (grep {$_->{nick} eq "$args"} Irssi::active_win()->{active}->nicks()); 
	my $r = $Nick->{host};
	$r =~ s/(.*)\@/\*\@/;
	$server->send_raw("PRIVMSG OperServ :akill add ".$r." killed (from ".$chan->{name}." (".$args."))");
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
				$server->send_raw("PRIVMSG OperServ :akill add ".pop(@{$buffer{$key}})." bot killed from ".$channame);
				select (undef, undef, undef, .25);
			}
		}
	}
	else {
		foreach(@{$buffer{$key}}) {
			$server->send_raw("PRIVMSG OperServ :akill add ".$_." bot killed from ".$channame);
			select (undef, undef, undef, .25);
		}
		@{$buffer{$key}} = ();
	}
}


Irssi::signal_add("message join", "msg_join");
Irssi::command_bind('botflood', 'botflood');
Irssi::command_bind('akill', 'akill');
