select teams.country as "team", count(team) as "matches" from involves join teams on teams.id = involves.team group by involves.team;

select Players.name as "player", count(scoredBy) as "goals" from Goals join Players on Players.id = Goals.scoredBy where rating = 'amazing' group by Goals.scoredBy having count(scoredBy) > 1;

select teams.country as team, count(players.id) as players from Players join teams on teams.id = players.memberOf where players.id not in (select scoredBy from Goals) group by players.memberof;

select matches.id as matchid,
        t1.id as team1id, t1.country as team1,
        t2.id as team2id, t2.country as team2
from   Matches
        join Involves i1 on (matches.id = i1.match)
        join Involves i2 on (matches.id = i2.match)
        join Teams t1 on (i1.team = t1.id)
        join Teams t2 on (i2.team = t2.id)
where  t1.country < t2.country;

select teams.country, count(players.id) as "reds" from players join cards on cards.givento = players.id join teams on players.memberof = teams.id where cardtype = 'red' group by players.memberof UNION select count(players.id) as "yellows" from players join cards on cards.givento = players.id join teams on players.memberof = teams.id where cardtype = 'yellow' or count(players.id) = 0 group by players.memberof;
