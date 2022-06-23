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
    location INT DEFAULT NULL REFERENCES location(venueId) ON UPDATE RESTRICT ON DELETE RESTRICT,
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


CREATE TABLE IF NOT EXISTS clique (
	cliqueId INT PRIMARY KEY AUTO_INCREMENT,
    genre VARCHAR(64) DEFAULT NULL
);


DROP TABLE IF EXISTS setlist;
CREATE TABLE IF NOT EXISTS setlist (
	setlistId INT PRIMARY KEY AUTO_INCREMENT,
    songs text NOT NULL
);
INSERT INTO setlist (songs)
	VALUES	('Fakin\' It, ...'),
			('Location, ...'),
			('Believer, Enemy, ...'),
            ('Thrift Shop, ...');


-- RELATIONS

CREATE TABLE IF NOT EXISTS attends (
	user VARCHAR(64) NOT NULL REFERENCES user(username) ON UPDATE RESTRICT ON DELETE RESTRICT,								-- PUT MORE THOUGHT INTO UPDATE AND DELETE
    concert INT NOT NULL REFERENCES concert(concertId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (user, concert)
);

CREATE TABLE IF NOT EXISTS performs (
	artist INT NOT NULL REFERENCES artist(artistId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    setlist INT NOT NULL REFERENCES setlist(setlistId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    concert INT NOT NULL REFERENCES concert(concertId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (artist, setlist, concert)
);

CREATE TABLE IF NOT EXISTS shares (
	user VARCHAR(64) NOT NULL REFERENCES user(username) ON UPDATE RESTRICT ON DELETE RESTRICT,
    concert INT NOT NULL REFERENCES concert(concertId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    clique INT NOT NULL REFERENCES clique(cliqueId) ON UPDATE RESTRICT ON DELETE RESTRICT,
    PRIMARY KEY (user, concert, clique)
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
call createUser('Alex');

INSERT INTO user VALUES ('Matt','Matt Keefer',19);

SELECT * FROM concert;
SELECT * FROM concert AS concerts WHERE concertId = 3;
INSERT INTO concert (name, concertDate) VALUES ('Governer\'s Ball New York', '2022-10-12');


DELIMITER //
CREATE PROCEDURE createUser (
	usr VARCHAR(64)
) 
BEGIN
	INSERT INTO user (username) VALUES (usr);
END//
