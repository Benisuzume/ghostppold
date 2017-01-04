<?php

/*

   uc-ghost
   Copyright [2016-2017] [Nuno Anselmo]

   This file is part of the uc-ghost source code.

   uc-ghost is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   uc-ghost source code is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with uc-ghost source code. If not, see <http://www.gnu.org/licenses/>.

   uc-ghost is modified from ent-ghost (https://github.com/uakfdotb/ent-ghost)
   ent-ghost is Copyright [2011-2013] [Jack Lu]

   ent-ghost is modified from GHost++ (http://ghostplusplus.googlecode.com/)
   GHost++ is Copyright [2008] [Trevor Hogan]

 */

# this file contains a list of cron functions that you may wish to use on your database
# you must provide each function with a mysqli database link from an external cron script
# note that this script ONLY DEFINES FUNCTIONS, and requires an external script to function

function escape($link, $str) {
	return $link->escape_string($str);
}

# updateBan will update your ban cache
# the ban cache is used so that host bots can quickly synchronize with the master ban list
#  without wasting bandwidth on bans that they already have
#  blank indicates a contextless ban, meaning that it applies globally
#  non-blank contexts indicate bans pertaining to a specific game owner
function updateBan($link) {
	# fix context for odd bans
	$link->query("UPDATE bans SET context = '' WHERE context IS NULL");

	# add unrecorded bans to the ban history, but only 1000 at a time
	$result = $link->query("SELECT id, server, name, ip, date, gamename, admin, reason, expiredate, botid FROM bans WHERE id > ( SELECT IFNULL(MAX(banid), 0) FROM ban_history ) AND context = '' ORDER BY id LIMIT 1000");

	while($result && $row = $result->fetch_array()) {
		$id = escape($link, $row[0]);
		$server = escape($link, $row[1]);
		$name = escape($link, $row[2]);
		$ip = escape($link, $row[3]);
		$date = escape($link, $row[4]);
		$gamename = escape($link, $row[5]);
		$admin = escape($link, $row[6]);
		$reason = escape($link, $row[7]);
		$expiredate = escape($link, $row[8]);
		$botid = escape($link, $row[9]);

		# insert into history table
		$link->query("INSERT INTO ban_history ( banid, server, name, ip, date, gamename, admin, reason, expiredate ) VALUES ('$id', '$server', '$name', '$ip', '$date', '$gamename', '$admin', '$reason', '$expiredate')");

		# put banid in ban cache so that bots can update to it
		$link->query("INSERT INTO bancache (banid, datetime, status) VALUES ('$id', NOW(), 0)"); # 0 means new ban, 1 means del ban
	}

	# update cache to reflect deleted bans
	$result = $link->query("UPDATE bancache SET status = '1', datetime = NOW() WHERE status = '0' AND (SELECT COUNT(*) FROM bans WHERE bans.id = banid) = 0");
}

# this will update the gametrack table
# the table keeps track of total games played, stay percentage, and other data
function gameTrack($link, $next_player) {

	# get the next 5000 players
	$result = $link->query("SELECT gameplayers.botid, name, spoofedrealm, gameid, gameplayers.id, (`left`/duration), duration FROM gameplayers LEFT JOIN games ON games.id = gameid WHERE gameplayers.id >= '$next_player' ORDER BY gameplayers.id LIMIT 5000");

	while($result && $row = $result->fetch_array()) {
		$botid = intval($row[0]);
		$name = escape($link, $row[1]);
		$realm = escape($link, $row[2]);
		$gameid = escape($link, $row[3]);
		$leftpercent = escape($link, $row[5]);
		$duration = escape($link, $row[6]);

		# see if this player already has an entry, and retrieve if there is
		$checkResult = $link->query("SELECT lastgames FROM gametrack WHERE name = '$name' AND realm = '$realm'");

		if($checkResult && $checkRow = $checkResult->fetch_array()) {
			# lastgames shifting-window arrays
			$lastgames = explode(',', $checkRow[0]);
			$lastgames[] = $gameid;

			if(count($lastgames) > 10) {
				array_shift($lastgames);
			}

			$lastString = escape($link, implode(',', $lastgames));
			$link->query("UPDATE gametrack SET lastgames = '$lastString', total_leftpercent = total_leftpercent + '$leftpercent', num_games = num_games + 1, time_active = NOW(), playingtime = playingtime + '$duration' WHERE name = '$name' AND realm = '$realm'");
		} else {
			$lastString = escape($link, $gameid);
			$link->query("INSERT INTO gametrack (name, realm, lastgames, total_leftpercent, num_games, time_created, time_active, playingtime) VALUES ('$name', '$realm', '$lastString', '$leftpercent', '1', NOW(), NOW(), '$duration')");
		}

		$next_player = $row[4] + 1;
	}

	return $next_player;
}

?>
