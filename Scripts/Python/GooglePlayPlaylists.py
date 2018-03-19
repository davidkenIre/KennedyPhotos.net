# Docs
# https://unofficial-google-music-api.readthedocs.io/en/latest/

# TODO
# 1. Need to limit the number of songs added to a playlist to 1000
# 2. Need to use the date updated, created etc

# Dependancies
# pip install gmusicapi

# Imports
from gmusicapi import Mobileclient
from winreg import *
import datetime
import mysql.connector

# Retrieve Credentials - Credentials re stored as 2 string vales in HKLM\Software\Lattuce
hKey = OpenKey(HKEY_LOCAL_MACHINE, "Software\\Lattuce")
GoogleUsername = QueryValueEx(hKey, "GoogleUsername")[0]
GooglePassword = QueryValueEx(hKey, "GooglePassword")[0]
MySQLUsername = QueryValueEx(hKey, "MySQLUsername")[0]
MySQLPassword = QueryValueEx(hKey, "MySQLPassword")[0]

# Log into Google
api = Mobileclient()
api.login(GoogleUsername, GooglePassword, Mobileclient.FROM_MAC_ADDRESS) # => True

# Table based playlists
playlistsongcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistsongcursor = playlistsongcnx.cursor()
playlistcursor = playlistcnx.cursor()

query = ("select s.album_name, s.song_name, s.filename, p.playlist_name from playlist p, playlist_song ps, song s where p.playlist_id = ps.playlist_id and ps.song_id = s.song_id and p.playlist_name = 'DKEN Playlist'")
playlistsongcursor.execute(query)
query = ("select playlist_name, playlist_id from playlist")
playlistcursor.execute(query)


# Recreate existing playlists
for (playlist_name, playlist_id) in playlistcursor:
    playlists = api.get_all_playlists()
    for playlist in playlists:
        if playlist['name'] == playlist_name:
            id_to_delete = playlist['id']
            print("Deleting Playlist:", playlist['name'], [id_to_delete])
            api.delete_playlist(id_to_delete)
    playlist_id = api.create_playlist(playlist_name)
    print("Creating Playlist:", playlist_name, [playlist_id])
playlistcursor.close()

# Add new Playlist
playlistsongs=[]
songs = api.get_all_songs()
for (album_name,  song_name, filename, playlist_name) in playlistsongcursor:
    for song in songs: 
        if song['album'] == album_name and song['title'] == song_name:
            # Get the playlist id we are adding to
            playlists = api.get_all_playlists()
            for playlist in playlists:
                if playlist['name'] == playlist_name:
                    playlist_id = playlist['id']
            print("Adding song:", song['title'], [song['id']], "to playlist:", playlist_name, [playlist_id])   
            playlistsongs.append(song['id'])
api.add_songs_to_playlist(playlist_id, playlistsongs)
playlistsongcursor.close()

# Close cursors
playlistcnx.close()
playlistsongcnx.close()
