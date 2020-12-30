# Docs
# https://ytmusicapi.readthedocs.io/en/latest/index.html

# TODO

# Dependancies
# pip install ytmusicapi

# Imports
import datetime
import mysql.connector
import os
import sys
from winreg import *
from ytmusicapi import YTMusic

# Encoding
#[SYSTEM.Environment]::SetEnvironmentVariable('PYTHONIOENCODING','utf-8',[System.EnvironmentVariableTarget]::Machine)
#[System.Environment]::SetEnvironmentVariable('PYTHONLEGACYWINDOWSSTDIO', 'utf-8',[System.EnvironmentVariableTarget]::Machine)

# Setup YTMusic
ytmusic = YTMusic('headers_auth.json')
ytmusicupload = YTMusic('headers_auth.json')

# Retrieve Credentials - Credentials re stored as 2 string vales in HKLM\Software\Lattuce
hKey = OpenKey(HKEY_LOCAL_MACHINE, "Software\\Lattuce")
MySQLUsername = QueryValueEx(hKey, "MySQLUsername")[0]
MySQLPassword = QueryValueEx(hKey, "MySQLPassword")[0]

# Setup Connections
songcnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
songcursor = songcnx.cursor()
songupdatecnx = mysql.connector.connect(user=(MySQLUsername), password=(MySQLPassword), host='lattuce-dc', database='music')
songupdatecursor = songupdatecnx.cursor()

# Download metadata for entire songs library
print ("Downloading metadata for entire songs library from YouTube Music...")
songs = ytmusic.get_library_upload_songs(100000)
###
f = open( 'D:\Data\Scripts\Powershell\Music\file.txt', 'w' )
f.write(  repr(songs) + '\n' )
f.close()
###

# Loop through each song and update the master DB with the entityid from YouTube music
print ("Looping through each song and update the master DB with the entityid from YouTube music...")
def make_unicode(input):
    if type(input) != str:
        input =  input.decode('utf-8') 
    return input

for song in songs:
    

    # Tidy up Albumname
    albumname=""
    x=song['album']
    albumname=str(x['name'])
    albumname=make_unicode(albumname)
    albumname=albumname.replace("'", "''")
        
    # Tidy up Songname
    songname = ""
    songname=str(song['title'])
    songname=make_unicode(songname)
    songname=songname.replace("'", "''")

    print("Found Album: " + albumname + ", Song: " + songname + " on YouTube Music")

    # Sync ID's    
    query = "select ssub.song_id from music.song ssub, music.album asub where ssub.album_id = asub.album_id and ssub.song_name = '" + songname + "' and asub.album_name = '" + albumname + "' and asub.active='Y' and ssub.active = 'Y' "    
    songcursor = songcnx.cursor(buffered=True)
    songcursor.execute(query)   
    if songcursor.rowcount == 1:
        record = songcursor.fetchone()[0]
        # print('Updating Master Song table with YouTube Music video id: ' + str(song['videoId']) + ' for song_id: ' + str(record))
        query = "update music.song set updated_date = current_date(), updated_by_id =  'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', youtubemusic_idSong = '" + str(song['videoId']) + "' where song_id = " + str(record)    
        songupdatecursor.execute(query)
        songupdatecnx.commit()
    else:
        print("Album: " + albumname + ", Song: " + songname + " not found in master database...")
