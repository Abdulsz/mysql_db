DROP TABLE IF EXISTS Song;
DROP TABLE IF EXISTS Playlist;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Album;
DROP TABLE IF EXISTS Artist;

CREATE TABLE Artist (
    artist_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    country_of_origin TEXT,
    genre TEXT,
    monthly_listeners INTEGER,
    founding_year INTEGER,
    Biography TEXT,
    image_url TEXT
);

CREATE TABLE Album (
    album_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    num_songs INTEGER,
    num_plays INTEGER DEFAULT 0,
    duration INTEGER,
    artist_id INTEGER,
    release_date DATE,
    album_type TEXT,
    image_url TEXT,
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

CREATE TABLE Playlist (
    playlist_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    creation_date DATE,
    Description TEXT
);

CREATE TABLE Playlist_Songs (
    playlist_id INTEGER,
    song_id INTEGER,
    PRIMARY KEY (playlist_id, song_id),
    FOREIGN KEY (playlist_id) REFERENCES Playlist(playlist_id),
    FOREIGN KEY (song_id) REFERENCES Song(song_id)
);

CREATE TABLE Song (
    song_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    number_of_plays INTEGER DEFAULT 0,
    duration INTEGER NOT NULL,
    artist_id INTEGER NOT NULL,
    album_id INTEGER NOT NULL,
    genre TEXT,
    release_date DATE,
    feature_artists TEXT,
    image_url TEXT,
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id)
);

CREATE VIEW Music AS
SELECT 
    Song.name AS song_name,
    Artist.name AS artist_name,
    Song.duration AS duration,
    Song.genre AS genre
FROM Song
JOIN Artist ON Song.artist_id = Artist.artist_id
JOIN Album ON Song.album_id = Album.album_id;


-- Artist Analytics: Shows total plays, average duration, and most popular album for each artist
CREATE VIEW ArtistAnalytics AS
SELECT 
 Artist.artist_id,
 Artist.name AS artist_name,
 COUNT(DISTINCT Song.song_id) AS total_songs,
 SUM(Song.number_of_plays) AS total_plays,
 AVG(Song.duration) AS avg_song_duration,
 (
  SELECT Album.name
  FROM Album
  JOIN Song AS S ON Album.album_id = S.album_id
  WHERE S.artist_id = Artist.artist_id
  GROUP BY Album.album_id
  ORDER BY SUM(S.number_of_plays) DESC
  LIMIT 1
 ) AS most_popular_album
FROM Artist
LEFT JOIN Song ON Artist.artist_id = Song.artist_id
GROUP BY Artist.artist_id, Artist.name;

-- Genre Analytics: Shows popularity of different genres
CREATE VIEW GenreAnalytics AS
SELECT 
 Song.genre,
 COUNT(Song.song_id) AS song_count,
 AVG(Song.number_of_plays) AS avg_plays,
 SUM(Song.number_of_plays) AS total_plays,
 MIN(Song.release_date) AS earliest_song,
 MAX(Song.release_date) AS latest_song
FROM Song
GROUP BY Song.genre
ORDER BY total_plays DESC;

-- Album Performance: Calculate metrics per album
CREATE VIEW AlbumPerformance AS
SELECT 
 Album.album_id,
 Album.name AS album_name,
 Artist.name AS artist_name,
 Album.release_date,
 COUNT(Song.song_id) AS track_count,
 SUM(Song.number_of_plays) AS total_plays,
 SUM(Song.number_of_plays) / COUNT(Song.song_id) AS avg_plays_per_track,
 SUM(Song.duration) AS total_duration
FROM Album
JOIN Artist ON Album.artist_id = Artist.artist_id
LEFT JOIN Song ON Album.album_id = Song.album_id
GROUP BY Album.album_id, Album.name, Artist.name, Album.release_date
ORDER BY avg_plays_per_track DESC;

-- 2. SET OPERATIONS

-- Finding similar songs - songs with the same genre as those in a specific playlist
CREATE VIEW SimilarSongsToPlaylist AS
WITH PlaylistGenres AS (SELECT DISTINCT Song.genre FROM Playlist_Songs JOIN Song ON Playlist_Songs.song_id = Song.song_id WHERE Playlist_Songs.playlist_id = 1 -- Replace with parameter
)
SELECT Song.song_id, Song.name AS song_name, Artist.name AS artist_name, Song.genre, Album.name AS album_name
FROM Song JOIN Artist ON Song.artist_id = Artist.artist_id JOIN Album ON Song.album_id = Album.album_id
WHERE Song.genre IN (SELECT genre FROM PlaylistGenres) AND Song.song_id NOT IN (SELECT song_id FROM Playlist_Songs WHERE playlist_id = 1 -- Replace with same parameter
);
