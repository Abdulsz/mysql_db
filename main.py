import os
from datetime import date
import sqlite3
from flask import Flask, render_template, request, url_for, flash, redirect, session, jsonify

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your secret key'

# Hardcoded user information
DEFAULT_USER_ID = 1  # You can choose any ID (it doesn't need to be in the db anymore)
DEFAULT_USERNAME = "defaultuser"
def get_db_connection():
    conn = sqlite3.connect('database.db')
    conn.row_factory = sqlite3.Row
    return conn

# Hardcoded user information
DEFAULT_USER_ID = 1  # You can choose any ID (it doesn't need to be in the db anymore)
DEFAULT_USERNAME = "defaultuser"

@app.route('/', methods=['POST', 'GET'])
def login():
    if request.method == 'POST':
        # Simply set the username in the session
        session['username'] = DEFAULT_USERNAME
        return redirect(url_for('home_page'))
    return render_template('login.html')
    

def get_userId():
    username = session.get('username')
    print(f"Session username: {username}")
    
    if username == DEFAULT_USERNAME:
        print(f"Found user ID: {DEFAULT_USER_ID}")
        return {'user_id': DEFAULT_USER_ID, 'username': DEFAULT_USERNAME}
    else:
        print(f"Invalid session username.")
        return None

@app.route("/music")

def music():
    conn = get_db_connection()
    music = conn.execute('SELECT * from Song').fetchall()
    albums = conn.execute('SELECT * from Album').fetchall()
    playlists = conn.execute('SELECT * from Playlist').fetchall()
    conn.close()
    return music

@app.route('/create_playlist', methods=['GET', 'POST'])
def create_playlist():
    user = get_userId()
    
    if request.method == 'POST':
        name = request.form['name']
        description = request.form['description']
        creation_date = date.today().isoformat()
        
        # Check if user is logged in
        if not user:
            flash('You must be logged in to create a playlist')
            #return redirect(url_for('login'))
            
        conn = get_db_connection()
        cur = conn.cursor()
        cur.execute("INSERT INTO Playlist(name, description, creation_date) VALUES (?, ?, ?)",
                    (name, description, creation_date))
        conn.commit()
        conn.close()
        flash('Playlist created successfully!')
        return redirect(url_for('playlists'))

    playlists = get_playlists()
    return render_template('playlistpage.html', playlists=playlists)

@app.route('/delete', methods=['POST'])
def delete_playlist():
    playlist_id = request.form['playlist_id']
    
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("DELETE FROM Playlist_Songs WHERE playlist_id = ?", (playlist_id,))
    cur.execute("DELETE FROM Playlist WHERE playlist_id = ?", (playlist_id,))
    conn.commit()
    conn.close()
    
    playlists = get_playlists()

    return render_template('playlistpage.html', playlists=playlists)



def get_playlists():
    conn = get_db_connection()
    cur = conn.cursor() 
    cur.execute("SELECT * FROM Playlist")
    playlists = cur.fetchall()
    conn.close()
    return playlists


def add_song_to_playlist(playlist_id, song_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute("INSERT INTO Playlist_Songs (playlist_id, song_id) VALUES (?, ?)", (playlist_id, song_id))
    conn.commit()
    conn.close()

def get_playlist_songs(playlist_id):
    conn = get_db_connection()
    cur = conn.cursor()
    cur.execute('''
        SELECT Song.name, Artist.name AS artist_name
        FROM Playlist_Songs
        JOIN Song ON Playlist_Songs.song_id = Song.song_id
        JOIN Artist ON Song.artist_id = Artist.artist_id
        WHERE Playlist_Songs.playlist_id = ?
    ''', (playlist_id,))
    songs = cur.fetchall()
    conn.close()
    return songs


@app.route("/search_music", methods=['GET', 'POST'])
def search_music():
    conn = get_db_connection()
    user_input = request.form['search']
    song_search = conn.execute('''
        SELECT 
            song_name,
            artist_name,
            duration,
            genre
        FROM Music
        WHERE song_name LIKE ? OR artist_name LIKE ?''', ('%' + user_input + '%', '%' + user_input + '%',)).fetchall()
    
    conn.close()
    print(song_search if song_search else "No music found")
    return render_template('index.html', music=song_search);
    

@app.route("/index")
def index():  
    conn = get_db_connection()
    music = conn.execute('''
        SELECT 
            song_name,
            artist_name,
            duration,
            genre
        FROM Music;
''').fetchall()
    
    conn.close()
    print(music if music else "No music found")
    return render_template('index.html', music=music)


@app.route("/playlists")
def playlists():
    playlists = get_playlists()   
    return render_template('playlistpage.html', playlists=playlists)

@app.route("/add_to_playlist", methods=["POST"])
def add_to_playlist():
    song_id = request.form['song_id']
    # Later: show a modal asking which playlist, for now assume playlist_id=1
    playlist_id = 1  
    add_song_to_playlist(playlist_id, song_id)
    return redirect(url_for('index'))


@app.route("/home")
def home_page():
    conn = get_db_connection()
    artists = conn.execute('SELECT * from Artist ORDER BY monthly_listeners DESC LIMIT 5').fetchall()
    songs = conn.execute('SELECT * from Song ORDER BY number_of_plays DESC LIMIT 5').fetchall()
    albums = conn.execute('SELECT * from Album WHERE album_id in (SELECT album_id from Song ORDER BY number_of_plays DESC) LIMIT 5').fetchall()
    conn.close()

    return render_template('home.html', artists=artists, songs=songs, albums=albums)



@app.route("/artist_analytics_data")
def artist_analytics_data():
 conn = get_db_connection()
 analytics = conn.execute('SELECT * FROM ArtistAnalytics').fetchall()
 conn.close()
    # Convert Row objects to dictionaries for JSON serialization
 analytics_list = [dict(row) for row in analytics]
 return jsonify(analytics_list)

@app.route("/genre_analytics_data")
def genre_analytics_data():
 conn = get_db_connection()
 genres = conn.execute('SELECT * FROM GenreAnalytics').fetchall()
 conn.close()
    # Convert Row objects to dictionaries for JSON serialization
 genres_list = [dict(row) for row in genres]
 return jsonify(genres_list)

@app.route("/album_performance_data")
def album_performance_data():
 conn = get_db_connection()
 albums = conn.execute('SELECT * FROM AlbumPerformance').fetchall()
 conn.close()
    # Convert Row objects to dictionaries for JSON serialization
 albums_list = [dict(row) for row in albums]
 return jsonify(albums_list)







app.run(host = '0.0.0.0', port = 82)