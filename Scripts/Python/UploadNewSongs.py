# Docs
# https://ytmusicapi.readthedocs.io/en/latest/index.html

# TODO

# Dependancies
# pip install ytmusicapi

# Imports
import datetime
import mysql.connector
import os
from winreg import *
from ytmusicapi import YTMusic

# Setup YTMusic
ytmusic = YTMusic('..\\python\\headers_auth.json')
ytmusicupload = YTMusic('..\\python\\headers_auth.json')

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

# Get the entire library listing from youtube music, then match to the files we have on the local master database,
# update the youtubemusic_idSong column with a natched file.  Then in the next section we'll upload missing songs

# Upload new songs
query = "select replace(replace(concat(path,  filename), 'smb:', ''), '/', '\\\\') as fullfilename, song_id from music.song where youtubemusic_idSong is null and active = 'Y'"
songcursor.execute(query)
records = songcursor.fetchall()
for row in records:
     fullfilename=row[0]
     song_id=row[1]
     print("Uploading Song: ", fullfilename)
     UploadResponse=ytmusicupload.upload_song(fullfilename)
     print("Youtube Music Response: ", UploadResponse)
