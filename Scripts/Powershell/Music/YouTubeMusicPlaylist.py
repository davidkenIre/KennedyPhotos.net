# Docs
# https://ytmusicapi.readthedocs.io/en/latest/index.html

# TODO
# Upload songs to ytmusic using API
# Album_name and song_name is not unique...
# Process indicator from db settings file is commented out
# Some albums are called FIXME<>

# Dependancies
# pip install ytmusicapi

# Imports
import datetime
import mysql.connector
import os
from winreg import *
from ytmusicapi import YTMusic

# Setup YTMusic
ytmusic = YTMusic('headers_auth.json')
ytmusicupload = YTMusic('headers_auth.json')

# Retrieve Credentials - Credentials re stored as 2 string vales in HKLM\Software\Lattuce
hKey = OpenKey(HKEY_LOCAL_MACHINE, "Software\\Lattuce")
GoogleUsername = QueryValueEx(hKey, "GoogleUsername")[0]
GooglePassword = QueryValueEx(hKey, "GooglePassword")[0]
MySQLUsername = QueryValueEx(hKey, "MySQLUsername")[0]
MySQLPassword = QueryValueEx(hKey, "MySQLPassword")[0]

# Setup Connections
playlistsongcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnxtodelete = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistdelcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx1 = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistcnx2 = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
songcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
playlistsongcursor = playlistsongcnx.cursor()
playlistcursor = playlistcnx.cursor()
playlistcursortodelete = playlistcnxtodelete.cursor()
playlistdelcursor = playlistdelcnx.cursor()
playlistcursor1 = playlistcnx1.cursor()
playlistcursor2 = playlistcnx2.cursor()
songcursor = songcnx.cursor()

# Delete all existing playlists on youtube music (Excluding Your Likes playlist)
playlists=ytmusic.get_library_playlists(10000)
for playlist in playlists:
    #  Only delete playlists which are maintained manually
    query = ("SELECT playlist_name, playlist_id FROM music.playlist where active = 'Y' and maintain_internally = 'Y'")
    playlistcursortodelete.execute(query)

    records = playlistcursortodelete.fetchall()
    for row in records:
        playlist_name=row[0]
        if playlist['title'] == playlist_name:
            id_to_delete = playlist['playlistId']
            print("Deleting Playlist:", playlist['title'], [id_to_delete])
            ytmusic.delete_playlist(id_to_delete)

# Create new playlists
query = ("select playlist_name, playlist_id from playlist p where p.active='Y' and maintain_internally = 'Y'" )
playlistcursor.execute(query)
for (playlist_name, playlist_id) in playlistcursor:
    found=0
    playlists=ytmusic.get_library_playlists(100) 
    for playlist in playlists:
        if playlist['title'] == playlist_name:
            found=1
            print("Found Playlist: ", playlist['title'])
    if found==0:
        print("Creating Playlist:", playlist_name)
        playlist_id = ytmusic.create_playlist(playlist_name, "")
        print("Created Playlist: ", playlist_id)

# Add Songs to a playlist
playlists=ytmusic.get_library_playlists(100)
for playlist in playlists:
    query=("select youtubemusic_idSong from music.playlist p, music.playlist_song ps, music.song s where p.active = 'Y' and p.maintain_internally = 'Y' and playlist_name = '" + playlist['title'] + "' and p.playlist_id = ps.playlist_id and ps.song_id = s.song_id")
    print(query)
    playlistsongcursor.execute(query)
    records = playlistsongcursor.fetchall()
    for row in records:
        youtubemusic_idSong=row[0]
        print("Adding " + str(youtubemusic_idSong) + " to playlist: " + str(playlist['playlistId']))
        ret=ytmusic.add_playlist_items(str(playlist['playlistId']), [str(youtubemusic_idSong)], "", False)            
playlistsongcursor.close()