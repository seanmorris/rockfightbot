use strict;
use warnings;
use RockFightBot;

my $bot = EchoBot->new(
	server => "moo.slashnet.org",
	port   => "6667",
	nick      => shift @ARGV,
	username  => "RFBLOL",
	name      => "RFBROFLLMAO",
	channels => [@ARGV],
);

$bot->run();
