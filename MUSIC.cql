// Create music_keyspace

CREATE KEYSPACE music_keyspace WITH replication = {'class':'SimpleStrategy', 'replication_factor': '1'}
AND durable_writes = true;

//use keyspace

use music_keyspace;

//Create address type

CREATE TYPE address (
street text,
city text,
postal_code int,
country text);

//Q1: Find User by name

//Tables

CREATE TABLE user(
user_name text,
paymentInfo text,
address map<text,frozen<address>>,
PRIMARY KEY(user_name)
)WITH COMMENT ='Q1 Find user by name';

//Q2:Find Song by name

//Tables

CREATE TABLE song(
song_name text,
artist text,
album text,
genre text,
year int,
count int, 
song_file blob,
PRIMARY KEY(song_name)
)WITH COMMENT='Q2 Find song by name';

//Q3: Find Songs played by a user, arranged in reversed chronological order (most recent first)

//Tables

CREATE TABLE songs_by_user(
song_name text,
user_name text,
date_played date,
PRIMARY KEY (user_name,date_played,song_name)
)WITH CLUSTERING ORDER BY (date_played DESC,song_name ASC)
AND COMMENT='Q3:Find songs played by a user (reverse chronological order)';

//Q4: Find playlist by name

//Tables

CREATE TABLE playlist(
playlist_name text,
description text,
genre text,
creator text,
PRIMARY KEY (playlist_name)
)WITH COMMENT ='Q4 Find playlist by name';

//Q5: Find playlist by genre

//Index

CREATE INDEX ON playlist(genre);

//Q6: Find playlist by creator

//Materialized view
//We use materialized view to find playlists by creator,since creator is of high cardinality

CREATE MATERIALIZED VIEW playlist_by_creator
AS SELECT creator, playlist_name
FROM playlist
WHERE creator IS NOT NULL AND playlist_name IS NOT NULL
PRIMARY KEY (creator, playlist_name)
WITH COMMENT ='Q6:Find playlist by creator';

//Q7: Find the followers of a playlist

//Tables
//We create new table since we can have millions of followers and we cannot insert more than 64K values

CREATE TABLE playlist_followers(
playlist_name text,
follower text, 
PRIMARY KEY(playlist_name,follower)
)WITH COMMENT = 'Q7 Find the followers of a playlist';

//Q8: Find the followers of a user

//Tables (same reason as Q7)

CREATE TABLE user_followers(
user_name text, 
follower text, 
PRIMARY KEY(user_name,follower)
)WITH COMMENT = 'Q8 Find the followers of a user';

//Q9: Find the songs contained in a playlist

CREATE TABLE playlist_songs(
playlist_name text, 
song_name text, 
PRIMARY KEY (playlist_name,song_name)
)WITH COMMENT = 'Q9 Find the songs contained in a playlist';

//Q10: Find how many times a playlist has been played

//Tables

CREATE TABLE playlist_no_of_times_played(
playlist_name text, 
times_played int, 
PRIMARY KEY (playlist_name)
)WITH COMMENT = 'Q10 Find how many times a playlist has been played';

//Q11: Find how many times a song has been played

//Tables

CREATE TABLE song_no_of_times_played(
song_name text, 
times_played int, 
PRIMARY KEY (song_name)
)WITH COMMENT = 'Q11 Find how many times a song has been played';

//Q12. List playlists in decreasing popularity 

//Tables

CREATE TABLE playlist_No_of_followers_desc(
id bigint,
playlist_name text,
no_followers int, 
PRIMARY KEY(id,no_followers) 
) WITH COMMENT = 'Q12:List playlists in decreasing popularity';

//Q13. List users in decreasing popularity 

//Tables

CREATE TABLE user_No_of_followers_desc(
id bigint,
user_name text,
no_followers int, 
PRIMARY KEY(id,no_followers) 
) WITH COMMENT = 'Q13:List users in decreasing popularity';



//Insert data

INSERT INTO user(user_name,paymentInfo,address) 
VALUES ('AngelicaChatz','PayPal',{'home':{street:'Mistra 12' ,city:'Athens',postal_code:16561,country:'Greece'}});

INSERT INTO user(user_name,paymentInfo,address)
VALUES ('AnastasiaRilmaheri','credit card',{'home':{street:'Platonos 120', city:'Athens',postal_code:11253,country:'Greece'}});

//Query

SELECT * FROM user WHERE user_name='AnastasiaRilmaheri';

//Insert data

INSERT INTO song(song_name,artist,album,genre,year,count)
VALUES ('Sexual Revolution','Army of Lovers','Glory Glamour and Gold',
'Dance',1994,6850045);

//Query

SELECT * FROM song WHERE song_name='Sexual Revolution';

//Insert data

INSERT INTO songs_by_user(song_name,user_name,date_played) 
VALUES ('lost on you','AngelicaChatz','2016-12-25');

INSERT INTO songs_by_user(song_name,user_name,date_played) 
VALUES ('partition','AnastasiaRilmaheri','2016-11-13');

INSERT INTO songs_by_user(song_name,user_name,date_played) 
VALUES ('cheyenne','AnastasiaRilmaheri','2016-08-19');

INSERT INTO songs_by_user(song_name,user_name,date_played) 
VALUES ('la vida es un carnaval','AngelicaChatz','2016-09-06');

//Query

SELECT * FROM songs_by_user WHERE user_name='AngelicaChatz' ORDER BY date_played DESC;

//Insert data

INSERT INTO playlist (playlist_name,description, genre, creator) 
VALUES ('Dance Hits','Dance Music','Dance','AngelicaChatz');

//Query

SELECT * FROM playlist WHERE playlist_name='Dance Hits';

//Query

SELECT * FROM playlist WHERE genre='Dance';

//Query

SELECT * FROM playlist_by_creator WHERE creator = 'AngelicaChatz';

//Query

SELECT follower FROM playlist_followers WHERE playlist_name='Dance Hits';

//Insert data

INSERT INTO user_followers(user_name, follower)
VALUES ('AngelicaChatz','AnastasiaRilmaheri');

INSERT INTO user_followers(user_name, follower)
VALUES ('AngelicaChatz','ChieIsilwen');

//Query

SELECT follower FROM user_followers WHERE user_name='AngelicaChatz';

//Insert data

INSERT INTO playlist_songs (playlist_name,song_name) 
VALUES ('Dance Hits','Sexual Revolution');

//Query

SELECT song_name FROM playlist_songs WHERE playlist_name='Dance Hits';

//Insert data

INSERT INTO playlist_no_of_times_played(playlist_name,times_played) 
VALUES ('Dance Hits',6669);

//Query

SELECT times_played FROM playlist_no_of_times_played WHERE  playlist_name = 'Dance Hits';

//Insert data

INSERT INTO song_no_of_times_played (song_name,times_played)
VALUES ('lost on you',1450069);

//Query

SELECT times_played FROM song_no_of_times_played  WHERE song_name='lost on you';

//Insert data

INSERT INTO playlist_No_of_followers_desc(id,playlist_name,no_followers) 
VALUES (1,'Dance Hits',32154);

INSERT INTO playlist_No_of_followers_desc(id,playlist_name,no_followers) 
VALUES (1,'Trip Hop',6669);

//Query

SELECT * FROM playlist_No_of_followers_desc WHERE id=1 ORDER BY no_followers DESC;

//Insert data

INSERT INTO user_No_of_followers_desc(id,user_name,no_followers) 
VALUES (0,'AngelicaChatz',654789);

INSERT INTO user_No_of_followers_desc(id,user_name,no_followers) 
VALUES (0,'AnastasiaRilmaheri',789654123);

//Query

SELECT * FROM user_No_of_followers_desc WHERE id=0 ORDER BY no_followers DESC;