-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema streamingly
-- -----------------------------------------------------
-- A planform for songs' streaming.
DROP SCHEMA IF EXISTS `streamingly` ;

-- -----------------------------------------------------
-- Schema streamingly
--
-- A planform for songs' streaming.
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `streamingly` ;
USE `streamingly` ;

-- -----------------------------------------------------
-- Table `streamingly`.`media`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`media` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`media` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `path` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `streamingly`.`albums`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`albums` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`albums` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'album\'s id',
  `name` VARCHAR(45) NOT NULL COMMENT 'name of the album',
  `image_media` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  INDEX `albums_image_media_idx` (`image_media` ASC) VISIBLE,
  CONSTRAINT `albums_image_media`
    FOREIGN KEY (`image_media`)
    REFERENCES `streamingly`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `streamingly`.`songs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`songs` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`songs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'song id',
  `album_id` INT UNSIGNED NOT NULL COMMENT 'album id',
  `title` VARCHAR(45) NOT NULL COMMENT 'title of the song',
  `filetype` VARCHAR(8) NOT NULL COMMENT 'type of the file (f.ex. mp4)',
  `song_media` INT UNSIGNED NOT NULL COMMENT 'pointer to the song',
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  INDEX `song_media_idx` (`song_media` ASC) VISIBLE,
  CONSTRAINT `album_id`
    FOREIGN KEY (`album_id`)
    REFERENCES `streamingly`.`albums` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `media`
    FOREIGN KEY (`song_media`)
    REFERENCES `streamingly`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `streamingly`.`genres`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`genres` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`genres` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'genre\'s id',
  `name` VARCHAR(45) NOT NULL COMMENT 'name of the genre',
  `image_media` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  INDEX `genres_image_media_idx` (`image_media` ASC) VISIBLE,
  CONSTRAINT `genres_image_media`
    FOREIGN KEY (`image_media`)
    REFERENCES `streamingly`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `streamingly`.`song_genre`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`song_genre` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`song_genre` (
  `song_id` INT UNSIGNED NOT NULL,
  `genre_id` INT UNSIGNED NOT NULL,
  CONSTRAINT `song_genre_song_id`
    FOREIGN KEY (`song_id`)
    REFERENCES `streamingly`.`songs` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `song_genre_genre_id`
    FOREIGN KEY (`genre_id`)
    REFERENCES `streamingly`.`genres` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'A table that will let us map songs with genres ----> n:m';


-- -----------------------------------------------------
-- Table `streamingly`.`artists`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`artists` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`artists` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT COMMENT 'artist\'s id',
  `name` VARCHAR(45) NOT NULL COMMENT 'name of the artist',
  `image_media` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE INDEX `id_UNIQUE` (`id` ASC) VISIBLE,
  INDEX `image_media_idx` (`image_media` ASC) VISIBLE,
  CONSTRAINT `image_media`
    FOREIGN KEY (`image_media`)
    REFERENCES `streamingly`.`media` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);


-- -----------------------------------------------------
-- Table `streamingly`.`song_artist`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`song_artist` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`song_artist` (
  `song_id` INT UNSIGNED NOT NULL,
  `artist_id` INT UNSIGNED NOT NULL,
  CONSTRAINT `song_artist_song_id`
    FOREIGN KEY (`song_id`)
    REFERENCES `streamingly`.`songs` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `sond_artist_artist_id`
    FOREIGN KEY (`artist_id`)
    REFERENCES `streamingly`.`artists` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
COMMENT = 'A table that will let us map songs with artists ----> n:m';


-- -----------------------------------------------------
-- Table `streamingly`.`rating`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `streamingly`.`rating` ;

CREATE TABLE IF NOT EXISTS `streamingly`.`rating` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `song_id` INT UNSIGNED NOT NULL,
  `count` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `rating_song_id_idx` (`song_id` ASC) VISIBLE,
  CONSTRAINT `rating_song_id`
    FOREIGN KEY (`song_id`)
    REFERENCES `streamingly`.`songs` (`id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

USE `streamingly` ;

-- -----------------------------------------------------
-- function add_album_to_genre
-- -----------------------------------------------------

USE `streamingly`;
DROP function IF EXISTS `streamingly`.`add_album_to_genre`;

DELIMITER $$
USE `streamingly`$$
CREATE FUNCTION add_album_to_genre (album_id int, genre_id int)
RETURNS int
DETERMINISTIC
BEGIN
    DECLARE id INT;
    DECLARE count INT;
    DECLARE done INTEGER DEFAULT false;
    DECLARE cur CURSOR FOR
    SELECT s.id FROM songs as s WHERE s.album_id = album_id;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = true;

    SET count = 0;
    
    OPEN cur;
    song_loop:
    LOOP
        FETCH cur into id;
        IF done = true THEN
            LEAVE song_loop;
        END IF;
        INSERT INTO song_genre(song_id, genre_id) VALUES(id, genre_id);
        SET count = count + 1;
        ITERATE song_loop;
    END LOOP;
    CLOSE cur;
    RETURN count;
END$$

DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `streamingly`.`media`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (1, 'till_paradiso.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (2, '01_Till_Paradiso_Frisco_Bar_at_Midnight.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (3, '02_Till_Paradiso_Ginger_Underground.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (4, '03_Till_Paradiso_I_need_your_Love.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (5, '04_Till_Paradiso_Wont_Say_This_the_Last_Time.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (6, '05_Till_Paradiso_Night_Prelude.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (7, '06_Till_Paradiso_Full_of_Love.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (8, '07_Till_Paradiso_Covid-19.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (9, '08_Till_Paradiso_Mr_Mix_Pickels.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (10, 'stay_tonight.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (11, 'prisma.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (12, 'andy_cohen.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (13, '01_Andy_G._Cohen_Hoist.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (14, '02_Andy_G._Cohen_Decapod.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (15, '03_Andy_G._Cohen_In_Awareness.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (16, '04_Andy_G._Cohen_Gazing.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (17, '05_Andy_G._Cohen_Minty_Soak.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (18, '06_Andy_G._Cohen_Our_Young_Guts.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (19, '07_Andy_G._Cohen_Epoxy_Resin.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (20, 'derek_clegg.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (21, 'man_on_the_run.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (22, '01_Derek_Clegg_Man_on_the_Run.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (23, '02_Derek_Clegg_A_Little_Bit_Down.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (24, '03_Derek_Clegg_Air_It_Out.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (25, '04_Derek_Clegg_Exist.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (26, '05_Derek_Clegg_When_We_Were_Young.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (27, '06_Derek_Clegg_Leading_Me_On.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (28, '07_Derek_Clegg_Coming_Of_Age.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (29, '08_Derek_Clegg_Covid_Blues.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (30, '09_Derek_Clegg_Rescue_Me.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (31, '10_Derek_Clegg_Long_Gone.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (32, 'daniel_birch.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (33, 'indigo.jpeg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (34, '01_Daniel_Birch_Blue_Deeper_Than_Indigo.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (35, '02_Daniel_Birch_Indigo_Shore.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (36, '03_Daniel_Birch_Indigo_Moon.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (37, '04_Daniel_Birch_Indigo_Blocks.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (38, '05_Daniel_Birch_Indigo_Strokes.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (39, '06_Daniel_Birch_Waves_Of_Indigo.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (40, '07_Daniel_Birch_Indigo_Girl.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (41, '08_Daniel_Birch_Indigo_Sun.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (42, '09_Daniel_Birch_Indigo_Heart.mp3');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (43, 'jazz.jpg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (44, 'rock.jpg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (45, 'pop.jpg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (46, 'electro.jpg');
INSERT INTO `streamingly`.`media` (`id`, `path`) VALUES (47, 'blues.jpg');

COMMIT;


-- -----------------------------------------------------
-- Data for table `streamingly`.`albums`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`albums` (`id`, `name`, `image_media`) VALUES (1, 'Stay Tonight', 10);
INSERT INTO `streamingly`.`albums` (`id`, `name`, `image_media`) VALUES (2, 'Prisma', 11);
INSERT INTO `streamingly`.`albums` (`id`, `name`, `image_media`) VALUES (3, 'Man on the Run', 21);
INSERT INTO `streamingly`.`albums` (`id`, `name`, `image_media`) VALUES (4, 'Indigo', 33);

COMMIT;


-- -----------------------------------------------------
-- Data for table `streamingly`.`songs`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Frisco Bar at Midnight', 'mp3', 2);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Ginger Underground', 'mp3', 3);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'I need your Love', 'mp3', 4);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Won\'t Say This the Last Time', 'mp3', 5);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Night Prelude', 'mp3', 6);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Full of Love', 'mp3', 7);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Covid-19', 'mp3', 8);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 1, 'Mr Mix Pickels', 'mp3', 9);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'Hoist', 'mp3', 13);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'Decapod', 'mp3', 14);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'In Awareness', 'mp3', 15);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'Gazing', 'mp3', 16);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'Minty Soak', 'mp3', 17);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'Our Young Guts', 'mp3', 18);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 2, 'Epoxy Resin', 'mp3', 19);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Man on the Run', 'mp3', 22);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'A Little Bit Down', 'mp3', 23);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Air It Out', 'mp3', 24);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Exist', 'mp3', 25);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'When We Were Young', 'mp3', 26);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Leading Me On', 'mp3', 27);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Coming Of Age', 'mp3', 28);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Covid Blues', 'mp3', 29);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Rescue Me', 'mp3', 30);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 3, 'Long Gone', 'mp3', 31);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Blue Deeper Than Indigo', 'mp3', 34);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Shore', 'mp3', 35);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Moon', 'mp3', 36);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Blocks', 'mp3', 37);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Strokes', 'mp3', 38);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Waves Of Indigo', 'mp3', 39);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Girl', 'mp3', 40);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Sun', 'mp3', 41);
INSERT INTO `streamingly`.`songs` (`id`, `album_id`, `title`, `filetype`, `song_media`) VALUES (NULL, 4, 'Indigo Heart', 'mp3', 42);

COMMIT;


-- -----------------------------------------------------
-- Data for table `streamingly`.`genres`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`genres` (`id`, `name`, `image_media`) VALUES (1, 'jazz', 43);
INSERT INTO `streamingly`.`genres` (`id`, `name`, `image_media`) VALUES (2, 'rock', 44);
INSERT INTO `streamingly`.`genres` (`id`, `name`, `image_media`) VALUES (3, 'pop', 45);
INSERT INTO `streamingly`.`genres` (`id`, `name`, `image_media`) VALUES (4, 'electronic', 46);
INSERT INTO `streamingly`.`genres` (`id`, `name`, `image_media`) VALUES (5, 'blues', 47);

COMMIT;


-- -----------------------------------------------------
-- Data for table `streamingly`.`song_genre`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (1, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (2, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (3, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (4, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (5, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (6, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (7, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (8, 1);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (9, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (10, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (11, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (12, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (13, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (14, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (15, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (16, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (16, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (17, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (17, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (18, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (18, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (19, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (19, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (20, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (20, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (21, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (21, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (22, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (22, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (23, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (23, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (24, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (24, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (25, 2);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (25, 3);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (18, 5);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (26, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (27, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (28, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (29, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (30, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (31, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (32, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (33, 4);
INSERT INTO `streamingly`.`song_genre` (`song_id`, `genre_id`) VALUES (34, 4);

COMMIT;


-- -----------------------------------------------------
-- Data for table `streamingly`.`artists`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`artists` (`id`, `name`, `image_media`) VALUES (1, 'Till Paradiso', 1);
INSERT INTO `streamingly`.`artists` (`id`, `name`, `image_media`) VALUES (2, 'Andy G. Cohen', 12);
INSERT INTO `streamingly`.`artists` (`id`, `name`, `image_media`) VALUES (3, 'Derek Clegg', 20);
INSERT INTO `streamingly`.`artists` (`id`, `name`, `image_media`) VALUES (4, 'Daniel Brich', 32);

COMMIT;


-- -----------------------------------------------------
-- Data for table `streamingly`.`song_artist`
-- -----------------------------------------------------
START TRANSACTION;
USE `streamingly`;
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (1, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (2, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (3, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (4, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (5, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (6, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (7, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (8, 1);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (9, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (10, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (11, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (12, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (13, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (14, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (15, 2);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (16, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (17, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (18, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (19, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (20, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (21, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (22, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (23, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (24, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (25, 3);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (26, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (27, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (28, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (29, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (30, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (31, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (32, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (33, 4);
INSERT INTO `streamingly`.`song_artist` (`song_id`, `artist_id`) VALUES (34, 4);

COMMIT;

USE `streamingly`;

DELIMITER $$

USE `streamingly`$$
DROP TRIGGER IF EXISTS `streamingly`.`songs_AFTER_INSERT` $$
USE `streamingly`$$
CREATE DEFINER = CURRENT_USER TRIGGER `streamingly`.`songs_AFTER_INSERT` AFTER INSERT ON `songs` FOR EACH ROW
BEGIN
	INSERT INTO rating(song_id, count) VALUES(NEW.id, 0);
END$$


DELIMITER ;

