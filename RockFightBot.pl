use strict;

use RockFightBot;

my $bot = EchoBot->new(
	server => "moo.slashnet.org",
	port   => "6667",
	channels => ['#totse'],

	nick      => "RFB",
	username  => "RFBLOL",
	name      => "RFBROFLLMAO",
);

$bot->run();
