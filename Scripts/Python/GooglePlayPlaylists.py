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

# Setup Connections
playlistsongcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnxtodelete = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistdelcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx1 = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx2 = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistsongcursor = playlistsongcnx.cursor()
playlistcursor = playlistcnx.cursor()
playlistcursortodelete = playlistcnxtodelete.cursor()
playlistdelcursor = playlistdelcnx.cursor()
playlistcursor1 = playlistcnx1.cursor()
playlistcursor2 = playlistcnx2.cursor()

################
# Delete playlists which dont exist in the database anymore
# TODO: Temp code until i can figure out how to truncate existing google playlists
playlists = api.get_all_playlists()
for playlist in playlists:
    id_to_delete = playlist['id']
    print("Deleting Playlist:", playlist['name'], [id_to_delete])
    api.delete_playlist(id_to_delete)
################

# Delete playlists which dont exist in the database anymore
playlists = api.get_all_playlists()
for playlist in playlists:
    print("Fround in Google:", playlist['name'])
    query = ("select Count(*) as cnt from playlist where playlist_name = '" + playlist['name'] + "'")
    playlistdelcursor.execute(query)
    row = playlistdelcursor.fetchone()
    if row[0] == 0:
        id_to_delete = playlist['id']
        print("Deleting Playlist:", playlist['name'], [id_to_delete], "because it does not exist in the database")
        api.delete_playlist(id_to_delete)
playlistdelcursor.close()

# Delete playlists where active = N
query = ("select playlist_name, playlist_id from playlist p where p.active='N'")
playlistcursortodelete.execute(query)
for (playlist_name, playlist_id) in playlistcursortodelete:
    playlists = api.get_all_playlists()
    for playlist in playlists:
        if playlist['name'] == playlist_name:
            id_to_delete = playlist['id']
            print("Deleting Playlist:", playlist['name'], [id_to_delete])
            api.delete_playlist(id_to_delete)
playlistcursortodelete.close()

# Create new playlists
query = ("select playlist_name, playlist_id from playlist p where p.active='Y'")
playlistcursor.execute(query)
for (playlist_name, playlist_id) in playlistcursor:
    found=0
    playlists = api.get_all_playlists()
    for playlist in playlists:
        if playlist['name'] == playlist_name:
            found=1
    if found==0:
        print("Creating Playlist:", playlist_name, [playlist_id])
        playlist_id = api.create_playlist(playlist_name)

# Add new Playlist
playlistsongs=[]
count=0
old_playlist_id=""
songs = api.get_all_songs()
query = ("select a.album_name, s.song_name, s.filename, p.playlist_name from playlist p, playlist_song ps, song s, album a where p.playlist_id = ps.playlist_id and s.album_id = a.album_id and ps.song_id = s.song_id order by p.playlist_name")
playlistsongcursor.execute(query)


#### TODO - album_name and song_name is not unique...
for (album_name,  song_name, filename, playlist_name) in playlistsongcursor:
    for song in songs: 
        if song['album'] == album_name and song['title'] == song_name:
            # Get the playlist id we are adding to
            playlists = api.get_all_playlists()            
            for playlist in playlists:
                if count == 0:
                    old_playlist_id = playlist['id']
                    count=1;
                if playlist['name'] == playlist_name:
                    playlist_id = playlist['id']
                    if playlist_id != old_playlist_id:
                        # We have a complete playlist add it
                        print("Commiting playlist:", [old_playlist_id])   
                        api.add_songs_to_playlist(old_playlist_id, playlistsongs)
                        old_playlist_id = playlist_id
                        playlistsongs = []                                       
                    print("Adding song:", song['title'], [song['id']], "to playlist:", playlist_name, [playlist_id])   
                    playlistsongs.append(song['id'])
# Add the last playlist                   
api.add_songs_to_playlist(playlist_id, playlistsongs)
playlistsongcursor.close()
