-- DROP DATABASE concertconnect;
CREATE DATABASE IF NOT EXISTS concertconnect;
USE concertconnect;


DROP TABLE IF EXISTS artist;
CREATE TABLE IF NOT EXISTS artist (
	artistId INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    age INT DEFAULT NULL,
    genre VARCHAR(64) DEFAULT NULL
);
INSERT INTO artist (name, age, genre)
	VALUES	('Kehlani', 27, 'R&B'),
			('Rico Nasty', 25, 'Hip-hop'),
            ('Burna Boy', 30, 'Hip-hop'),
            ('Sigrid', 25, 'Pop'),
            ('Imagine Dragons', null, 'Pop'),
            ('Macklemore', 39, 'Hip-hop');


DROP TABLE IF EXISTS location;
CREATE TABLE IF NOT EXISTS location (
	venueId INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL,
    street VARCHAR(64) NOT NULL,
    city VARCHAR(64) NOT NULL,
    state CHAR(2) NOT NULL
);
INSERT INTO location (name, street, city, state)
	VALUES 	('Leader Bank Pavillion', '290 Northern Ave', 'Boston', 'MA'),
			('House of Blues Boston', '15 Landsdowne St', 'Boston', 'MA'),
            ('Fenway Park', '4 Jersey St', 'Boston', 'MA');


DROP TABLE IF EXISTS concert;
CREATE TABLE IF NOT EXISTS concert (
	concertId INT PRIMARY KEY AUTO_INCREMENT,
    name text NOT NULL,
    minAge INT DEFAULT NULL,
    price DECIMAL(6, 2) DEFAULT NULL,
    concertDate DATE NOT NULL,
    location INT NOT NULL REFERENCES location(venueId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    genre VARCHAR(64) DEFAULT NULL
);
INSERT INTO concert (name, minAge, price, concertDate, location, genre)
	VALUES	('Kehlani: Blue Water Road Trip', null, 39.50, '2022-08-12', 1, 'Hip-hop/R&B'),
			('Burna Boy: Love, Damini', null, 79.50, '2022-07-29', 1, 'Hip-hop'),
            ('Sigrid: How to Let Go Tour', 18, 25, '2022-09-30', 2, 'Pop'),
            ('Imagine Dragons: Mercury World Tour', null, 170, '2022-08-20', 3, 'Pop');


CREATE TABLE IF NOT EXISTS user (
    username VARCHAR(64) PRIMARY KEY,
    name VARCHAR(64) DEFAULT NULL,
    age INT DEFAULT null
);


DROP TABLE IF EXISTS clique;
CREATE TABLE IF NOT EXISTS clique (
	cliqueId INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(64) NOT NULL UNIQUE,
    genre VARCHAR(64) NOT NULL
);
INSERT INTO clique (name, genre)
	VALUES	('Old Heads', 'Hip-hop'),
			('Pop Fiends', 'Pop');


-- RELATIONS


CREATE TABLE IF NOT EXISTS attends (
	user VARCHAR(64) NOT NULL REFERENCES user(username) ON UPDATE RESTRICT ON DELETE RESTRICT,								-- PUT MORE THOUGHT INTO UPDATE AND DELETE
    concert INT NOT NULL REFERENCES concert(concertId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (user, concert)
);


DROP TABLE IF EXISTS performs;
CREATE TABLE IF NOT EXISTS performs (
	artist INT NOT NULL REFERENCES artist(artistId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    concert INT NOT NULL REFERENCES concert(concertId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (artist, concert)
);
INSERT INTO performs
	VALUES	(1, 1), (2, 1),
            (3, 2),
            (4, 3),
            (5, 4), (6,4);


CREATE TABLE IF NOT EXISTS shares (
    concert INT NOT NULL REFERENCES concert(concertId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    clique INT NOT NULL REFERENCES clique(cliqueId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (concert, clique)
);


CREATE TABLE IF NOT EXISTS member (
	user VARCHAR(64) NOT NULL REFERENCES user(username) ON UPDATE RESTRICT ON DELETE RESTRICT,
    clique INT NOT NULL REFERENCES clique(cliqueId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (user, clique)
);








DELIMITER //
CREATE FUNCTION numUsersWithUsername (
	usr VARCHAR(64)
) RETURNS INT DETERMINISTIC READS SQL DATA
BEGIN
	DECLARE num_users INT;
    SELECT COUNT(*)
		FROM (SELECT * FROM user WHERE username = usr) AS users_w_usr
        INTO num_users;
	RETURN num_users;
END//

DELIMITER ;

SELECT numUsersWithUsername('Matt');
SELECT * FROM user;

INSERT INTO user VALUES ('matt','Matt Keefer',19);

SELECT * FROM clique;
SELECT * FROM shares WHERE clique = 1;
SELECT * FROM member;
SELECT * FROM clique
		LEFT OUTER JOIN (SELECT clique, COUNT(*) AS members FROM member GROUP BY clique) AS num ON cliqueId = clique;
        
SELECT * FROM clique
		JOIN (SELECT * FROM member WHERE user = 'matt') AS members
        ON cliqueId = clique;
-- call cliquesWithUser('john');


SELECT clique, COUNT(*) AS members FROM member GROUP BY clique;
-- CALL joinClique('john', 2);

SELECT * FROM concert;
SELECT * FROM concert AS concerts WHERE concertId = 3;
SELECT * FROM attends;
SELECT * FROM shares;
-- call notAttending('john', 1);
-- SELECT isAttending('matt', 1);

-- call updateUserInfo('Matt', 'Matt Keefer', 19);
-- call attending('Matt', 4);
-- call artistsPerforming(1);
call concertsAttending('matt');
call cliqueMembership();

-- call leaveClique('john', 2);
SELECT * FROM clique
		LEFT OUTER JOIN 
			(SELECT clique, COUNT(*) AS members FROM member GROUP BY clique) AS num 
			ON cliqueId = clique
		WHERE cliqueId NOT IN (SELECT clique FROM member WHERE user = 'matt');
        
SELECT * FROM user
		JOIN (SELECT * FROM member WHERE clique = 1) AS members
        ON username = user;

SELECT shares.*, concert.name FROM shares
		JOIN concert ON concert = concertId
        WHERE clique = 1;
        
        
SELECT * FROM clique
		JOIN member ON cliqueId = clique
        WHERE user = 'matt' AND cliqueId NOT IN (SELECT clique FROM shares WHERE clique = 1 AND concert = 2);



DELIMITER //

CREATE PROCEDURE cliquesWithUserNotShared (
	usr VARCHAR(64),
    con INT)
BEGIN
	SELECT * FROM clique
		JOIN member ON cliqueId = clique
        WHERE user = usr AND cliqueId NOT IN (SELECT clique FROM shares WHERE concert = con);
END//


CREATE PROCEDURE cliquesWithUser (
	usr VARCHAR(64))
BEGIN
	SELECT * FROM clique
		JOIN member ON cliqueId = clique
        HAVING member.user = usr;
END//


CREATE PROCEDURE concertsSharedWithClique (
	clq INT)
BEGIN
	SELECT shares.*, concert.name FROM shares
		JOIN concert ON concert = concertId
        WHERE clique = clq;
END//





CREATE PROCEDURE shareConcert (
    con INT,
    clq INT)
BEGIN
	INSERT INTO shares (concert, clique)
		VALUES (con, clq);
END//





CREATE PROCEDURE createClique (
	usr VARCHAR(64),
	clique_name VARCHAR(64),
    clique_genre TEXT)
BEGIN
	DECLARE new_clique_id INT;
	IF (clique_name = '' OR clique_genre = '') THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid name or genre';
    END IF;
	INSERT INTO clique (name, genre)
		VALUES (clique_name, clique_genre);
	SELECT cliqueId FROM clique WHERE name = clique_name AND genre = clique_genre
		INTO new_clique_id;
	INSERT INTO member (user, clique)
		VALUES (usr, new_clique_id);
END//