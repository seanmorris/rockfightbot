use strict;
package EchoBot;

use Bot::BasicBot;
use Data::Dumper;

use base qw( Bot::BasicBot );

sub new{
	my $class = shift;

	my $self = Bot::BasicBot->new(@_);

	$self->{players} = {};

	bless $self, $class;

	return $self;
}

sub interpret{
	my ($self, $message, $emoted) = @_;

	if(!$self->playerExists($message->{who}))
	{
		$self->registerPlayer($message->{who});
	}

	if((time() - $self->{players}{$1}{lastTurn}) < 5)
	{
		return;
	}
	
	$self->{players}{$1}{lastTurn} = time();

	if($message->{body} =~ /heals (\S+)/ && $emoted)
	{
		if($1 eq $message->{who})
		{
			return sprintf "Don't be stupid, %s.", $1;
		}

		if(!exists ($self->channel_data($message->{channel})->{$1}))
		{
			return $1 . ' doesnt exist.';
		}

		if(!$self->playerExists($1))
		{
			$self->registerPlayer($1);
		}

		$self->{players}{$1}{lastTurn} = time();
		
		if($self->{players}{$1}{isOnFire})
		{
			$self->{players}{$1}{isOnFire} = 0;

			return sprintf
				"%s is no longer on fire"
				, $1
		}

		if($self->{players}{$1}{isA})
		{
			my $was = $self->{players}{$1}{isA};

			$self->{players}{$1}{isA} = 0;

			return sprintf
				"%s is no longer a %s"
				, $1
				, lc($was);
		}

		if($self->{players}{$1}{hp} >= 100)
		{
			return $1 . '\'s HP is full. Stop it.';
		}

		my $worked = int(rand(10));

		if($worked < 2)
		{
			return 'Healing ' . $1 . ' failed.';
		}
		else
		{
			$self->{players}{$1}{hp} += 10;

			if($self->{players}{$1}{hp} >= 100)
			{
				$self->{players}{$1}{hp} = 100;
			}

			return sprintf
				'Healing %s Succeeded. +10 HP. (now %d)'
				, $1
				, $self->{players}{$1}{hp};
		}
	}

	if($message->{body} =~ /sets (\S+) on fire/)
	{
		if($self->{players}{$message->{who}}{hp} == 0)
		{
			return sprintf
				"Dead people can't set fires, %s"
				, $message->{who};
		}

		if($self->{players}{$message->{who}}{isA})
		{
			return sprintf
				"A %s can't start fires, %s."
				, lc($self->{players}{$message->{who}}{isA})
				, $message->{who};
		}

		my $hit = int(rand(10));

		if($hit < 2)
		{
			return 'The fire didn\'t catch';
		}
		else
		{
			if($self->{players}{$1}{hp} > 0)
			{
				$self->{players}{$1}{isOnFire} = 1;
			}
			else
			{
				$self->{players}{$1}{isOnFire} = 1;
			}
		}
	}

	if($message->{body} =~ /throws a (magi)?rock at (\S+)/)
	{
		if($2 eq $message->{who})
		{
			return sprintf "Don't be stupid, %s.", $2;
		}

		if($self->{players}{$message->{who}}{hp} == 0)
		{
			return sprintf
				"Dead people can't throw rocks, %s"
				, $message->{who};
		}

		if($self->{players}{$message->{who}}{isA})
		{
			return sprintf
				"A %s can't throw rocks, %s."
				, lc($self->{players}{$message->{who}}{isA})
				, $message->{who};
		}

		my $playerHit = $2;

		if(!exists ($self->channel_data($message->{channel})->{$playerHit}))
		{
			return $playerHit . ' doesnt exist.';
		}

		if(!$self->playerExists($playerHit))
		{
			$self->registerPlayer($playerHit);
		}

		if(!$self->{players}{$playerHit}{hp})
		{
			return sprintf $playerHit . ' is dead. Stop it, %s', $message->{who};
		}

		my $hit = int(rand(10));

		if($hit < 2)
		{
			return sprintf '%s\'s rock missed ' . $playerHit . '.', $message->{who};
		}
		elsif($hit > 7)
		{
			$self->{players}{$playerHit}{hp} -= 20;

			if($self->{players}{$1}{hp} <= 0)
			{
				$self->{players}{$1}{hp} = 0;
			}

			if($1 eq 'magic ')
			{
				my $trans = int(rand(10));

				if($trans > 4)
				{
					$self->{players}{$playerHit}{isA} = 'Duck';

					return sprintf "%s turned into a duck instead of taking damage.", $playerHit;
				}
			}

			return sprintf
				'%s\'s rock hit %s right in the eye! -20 HP! (%d left)'
				, $message->{who}
				, $playerHit
				, $self->{players}{$playerHit}{hp};
		}
		else
		{
			if($1 eq 'magic ')
			{
				my $trans = int(rand(10));

				if($trans > 4)
				{
					$self->{players}{$playerHit}{isA} = 'Chicken';

					return sprintf
						"%s turned into a chicken instead of taking damage."
						, $playerHit;
				}
			}

			$self->{players}{$playerHit}{hp} -= 10;

			if($self->{players}{$1}{hp} <= 0)
			{
				$self->{players}{$1}{hp} = 0;
			}

			return sprintf
				'The rock hit %s! -10 HP! (%d left)'
				, $playerHit
				, $self->{players}{$playerHit}{hp};
		}
	}

	if($message->{body} =~ /get players/)
	{
		return;
		return join ', ', map{
			$_ . ':' . $self->{players}{$_}{hp};
		} (keys %{ $self->{players} });
	}
}

sub registerPlayer{
	my ($self, $playerName) = @_;
	my %players = %{ $self->{players} };

	if(!exists $players{$playerName})
	{
		$self->{players}{$playerName} = {
			hp => 100
			, isA => 0
			, isOnFire => 0
			, lastTurn => 0
		};
	}
}

sub playerExists{
	my ($self, $playerName) = @_;

	my %players = %{ $self->{players} };

	return exists $players{$playerName};
}

sub said{
	my ($self, $message) = @_;

	foreach my $player (keys $self->channel_data($message->{channel}))
	{
		$self->registerPlayer($player);
	}

	my $interpret = $self->interpret( $message );
	my $additional = '';

	if($self->{players}{$message->{who}}{isOnFire})
	{
		$self->{players}{$message->{who}}{hp} -= 5;

		$additional = sprintf
			"\n" . '%s is slowly burning. -5 HP (%d left)'
			, $message->{who}
			, $self->{players}{$message->{who}}{hp};
	}

	return $interpret . $additional;
};

sub emoted{
	my ($self, $message) = @_;

	return $self->interpret( $message, 1 );
};

return 1;
