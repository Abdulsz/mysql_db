
-- Drop existing tables if they exist
DROP TABLE IF EXISTS Song; -- Assuming this was a song table and needs to be dropped
DROP TABLE IF EXISTS Playlist;
DROP TABLE IF EXISTS Users;
DROP TABLE IF EXISTS Album;
DROP TABLE IF EXISTS Artist;

-- Create Artist Table
CREATE TABLE Artist (
    artist_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    country_of_origin TEXT,
    genre TEXT,
    monthly_listeners INTEGER,
    founding_year INTEGER,
    Biography TEXT
);

-- Create Album Table
CREATE TABLE Album (
    album_id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    num_songs INTEGER,
    num_plays INTEGER DEFAULT 0,
    duration INTEGER, -- in minutes
    artist_id INTEGER,
    release_date DATE,
    album_type TEXT, -- (studio, live, compilation)
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id)
);

-- Create Playlist Table
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
    duration INTEGER NOT NULL, -- in seconds
    artist_id INTEGER NOT NULL,
    album_id INTEGER NOT NULL,
    genre TEXT,
    release_date DATE,
    feature_artists TEXT,
    FOREIGN KEY (artist_id) REFERENCES Artist(artist_id),
    FOREIGN KEY (album_id) REFERENCES Album(album_id)
);
