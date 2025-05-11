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
