-- Automatically validate the bans before insertion
DROP TRIGGER IF EXISTS BanValidator_Insert;
DELIMITER //
CREATE TRIGGER BanValidator_Insert BEFORE INSERT ON bans
  FOR EACH ROW
  BEGIN
    -- Correct anomalous context
    IF new.context IS NULL THEN
      SET new.context = '';
    END IF;
  END//
DELIMITER ;

-- Automatically validate the bans before update
DROP TRIGGER IF EXISTS BanValidator_Update;
DELIMITER //
CREATE TRIGGER BanValidator_Update BEFORE UPDATE ON bans
  FOR EACH ROW
  BEGIN
    -- Correct anomalous context
    IF new.context IS NULL THEN
      SET new.context = '';
    END IF;
  END//
DELIMITER ;

-- Automatically update the bancache and ban_history tables when a ban is inserted
DROP TRIGGER IF EXISTS BanUpdater_Insert;
DELIMITER //
CREATE TRIGGER BanUpdater_Insert AFTER INSERT ON bans
  FOR EACH ROW
  BEGIN
    IF new.context = '' THEN
      -- Track this ban in the ban_history table
      INSERT INTO ban_history
      SET `banid` = new.id,
          `server` = new.server,
          `name` = new.name,
          `ip` = new.ip,
          `date` = new.date,
          `gamename` = new.gamename,
          `admin` = new.admin,
          `reason` = new.reason,
          `expiredate` = new.expiredate;

      -- Add to the bancache to make bot updates faster
      INSERT INTO bancache
      SET `banid` = new.id,
          `datetime` = new.date,
          `status` = 0;
    END IF;
  END//
DELIMITER ;

-- Automatically update the ban_history tables when a ban is updated
DROP TRIGGER IF EXISTS BanUpdater_Update;
DELIMITER //
CREATE TRIGGER BanUpdater_Update AFTER UPDATE ON bans
  FOR EACH ROW
  BEGIN
    IF new.context = '' THEN
      -- Add this ban update to the ban_history table
      INSERT INTO ban_history
      SET `banid` = new.id,
          `server` = new.server,
          `name` = new.name,
          `ip` = new.ip,
          `date` = new.date,
          `gamename` = new.gamename,
          `admin` = new.admin,
          `reason` = new.reason,
          `expiredate` = new.expiredate;

      -- If the old ban wasn't contextless
      IF old.context != '' THEN
        INSERT INTO bancache
        SET `banid` = new.id,
            `datetime` = new.date,
            `status` = 0;
      ELSE
        UPDATE bancache
        SET `banid` = new.id,
            `datetime` = new.date
        WHERE `banid` = old.id AND
              `datetime` = old.date;
      END IF;

    -- If the new ban isn't contextless but the old one was
    ELSEIF old.context = '' THEN
      DELETE FROM bancache
      WHERE `banid` = old.id AND
            `datetime` = old.date;
    END IF;
  END//
DELIMITER ;

-- Automatically disable a ban in the bancache if the original ban has been removed
DROP TRIGGER IF EXISTS BanCacheUpdater_Delete;
DELIMITER //
CREATE TRIGGER BanCacheUpdater_Delete AFTER DELETE ON bans
  FOR EACH ROW
  BEGIN
    -- Correct anomalous context
    UPDATE bancache
    SET `status` = 1,
        `datetime` = NOW()
    WHERE `status` = 0 AND
          `banid` = old.id;
  END//
DELIMITER ;

-- Automatically recalculate player scores on the gametrack table
DROP TRIGGER IF EXISTS GameTrackUpdater_Insert;
DELIMITER //
CREATE TRIGGER GameTrackUpdater_Insert AFTER INSERT ON gameplayers
  FOR EACH ROW
  BEGIN
    -- Variables start with "v_" to avoid name conflicts
    DECLARE v_duration INTEGER;
    DECLARE v_lastgames VARCHAR(100);

    -- Find total game duration from game player was in
    SELECT `duration`
    INTO   v_duration
    FROM   games
    WHERE  `id` = new.gameid AND
           `botid` = new.botid;

    -- Create a list of the last 10 games played by this player
    -- Do this by concatenating the new game with the last 9 games played.
    SELECT SUBSTRING_INDEX(`lastgames`, ',', 9)
    INTO   v_lastgames
    FROM   gametrack
    WHERE  `name` = new.name AND
           `realm` = new.spoofedrealm;

    SELECT CONCAT_WS(',', new.gameid, v_lastgames)
    INTO   v_lastgames;

    -- Add user to the gametrack table, or update his status
    INSERT INTO gametrack
    SET `name` = new.name,
        `realm` = new.spoofedrealm,
        `lastgames` = v_lastgames,
        `total_leftpercent` = new.left / v_duration,
        `num_games` = 1,
        `time_created` = NOW(),
        `time_active` = NOW(),
        `playingtime` = new.left
    ON DUPLICATE KEY
    UPDATE `lastgames` = v_lastgames,
           `total_leftpercent` = total_leftpercent + (new.left / v_duration),
           `num_games` = num_games + 1,
           `time_active` = NOW(),
           `playingtime` = playingtime + new.left;
  END//
DELIMITER ;
