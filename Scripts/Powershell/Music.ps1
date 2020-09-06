<#  
.SYNOPSIS  
    Generate Kody playlists  
.DESCRIPTION  
    This script generates Kodi playlists and writes them 
	directly to the playlist folder in Kodi
.LINK  
#>

# Types
Add-Type –Path 'c:\program files\Lattuce\MySql.Data.dll'

# GetValues from Registry
$LattuceRegKey=Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Lattuce

# Open a database connection
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString=''}
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet

try {
	$Connection.ConnectionString="server=$($LattuceRegKey.MySQLServer);uid=$($LattuceRegKey.MySQLUsername);pwd=$($LattuceRegKey.MySQLPassword);database=$($LattuceRegKey.KodiMusicSchema)"
	$Connection.Open()
	$MYSQLCommand.Connection=$Connection

	###############################################
	# If there are any duplicate song titles within an album, then stop processing because
	# song matching between different databases requires unique song names within albums
	# duplicates will need to be fixed manually
	Write-Output "Checking for song titles within an album..."
	$Sql = "select count(*) dupcount from "
	$Sql += "(select a.strAlbum, s.strTitle, count(*) cnt from mymusic72.song s, mymusic72.album a  "
	$Sql += "where s.idAlbum = a.idAlbum "
	$Sql += "group by a.strAlbum, s.strTitle "
	$Sql += "order by 3 desc) sub "
	$Sql += "where sub.cnt > 1 "
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()
	if ($Setting -ne 0) {
		throw "Duplicate song titles within an Album"
	}

	###############################################
	# Check for NULL Album Names
	Write-Output "Checking for NULL Album Names..."
	$Sql = "select count(*) cnt from mymusic72.album a where a.strAlbum = '' "
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()
	if ($Setting -ne 0) {
		throw "Found NULL Album names in Kodi Database"
	}

	###############################################
	# Check for NULL Song Names
	Write-Output "Checking for NULL Song Names..."
	$Sql = "select count(*) cnt from mymusic72.song a where a.strTitle = '' "
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()
	if ($Setting -ne 0) {
		throw "Found NULL Song names in Kodi Database"
	}

	###############################################
	# Keep the master song tables in sync with the Kodi databases

	# Add new Albums from Kodi Music database to the Master Music database
	Write-Output "Adding Albums from Kodi music database to Master music database..."
	$Sql = "insert into music.album (created_date, created_by_id, album_name, active) "
	$Sql += "select distinct curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', a.strAlbum, 'Y' "
	$Sql += "from mymusic72.album a "
	$Sql += "where a.strAlbum not in "
	$Sql += "(select ta.album_name from music.album ta)"
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()

	# Deactivate from Master database any albums which no longer exist in Kodi database
	Write-Output "Deactiviating albums in Master Database which no longer exist in Kodi music database..."
	$Sql = "update music.album a set active = 'N', updated_date = curdate(), updated_by_id ='feb66d43-7615-4dbe-93f1-73cc4b4bf2a3'"
	$Sql += "where a.album_name not in (select ta.strAlbum from mymusic72.album ta)"
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()

	# Add New Songs to Master database from Kodi database
	Write-Output "Adding Songs from Kodi music database to Master music database..."
	$Sql = "insert into music.song (created_date, created_by_id, album_id, song_name, path, filename, play_count, kodi_idSong, active) "
	$Sql += "select curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', ma.album_id, s.strTitle, p.strPath, s.strFileName, 0, s.idSong, 'Y' "
	$Sql += "from mymusic72.song s, mymusic72.album a, mymusic72.path p, music.album ma "
	$Sql += "where s.idAlbum = a.idAlbum "
	$Sql += "and s.idPath = p.idPath "
	$Sql += "and a.strAlbum = ma.album_name "
	$Sql += "and s.idSong not in "
	$Sql += "(select ts.kodi_idSong from music.song ts)"
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()

	# Remove songs from Master, which no longer exist in the Kodi database
	Write-Output "Deactiviating songs in Master Database which no longer exist in Kodi music database..."
	$Sql = "update music.song set active = 'N', updated_date = curdate(), updated_by_id = 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3' "
	$Sql += "where kodi_idSong not in "
	$Sql += "(select s.idSong "
	$Sql += "from mymusic72.song s, mymusic72.album a, mymusic72.path p "
	$Sql += "where s.idAlbum = a.idAlbum "
	$Sql += "and s.idPath = p.idPath)"
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()

	###############################################
	# Update the General playlists
	Write-Output "Recreating file based (.m3u) playlists..."
	$Year=get-date -Format yyyy
	$OutputFile = "\\media-sr.lattuce.com\Userdata\playlists\music", 
				  "\\media-st.lattuce.com\Userdata\playlists\music",
				  "d:\media\music\master\playlists"
               
	# Create a list of Playlists
	$PlayLists = New-Object System.Collections.ArrayList

	# Playlist 1 - New Music added in the current Year
	$PlayList = New-Object System.Object
	$Sql = 'SELECT "#EXTM3U"
			UNION ALL
			SELECT CONCAT ("#EXTINF:", iDuration, ", ", strArtistDisp, " - ", strTitle, char(13), char(10), p.strPath, s.strFileName )   
			FROM mymusic72.song s, mymusic72.path p
			where s.dateAdded is not null
			and s.dateAdded >= STR_TO_DATE(''01,01,' + $($Year) + ''',''%d,%m,%Y'')
			and s.idPath = p.idPath;'
	$PlayList | Add-Member -MemberType NoteProperty -Name "Sql" -Value $Sql
	$PlayList | Add-Member -MemberType NoteProperty -Name "File" -Value "Music Added in $($Year).m3u"
	$PlayLists.Add($PlayList) | Out-Null

	# Playlist 2
	# You can add a new playlist object like the list above here...

	# Loop through the Playlists
	for($i = 0; $i -lt $PlayLists.Count; $i++) {
		$MYSQLCommand.CommandText = $PlayLists[$i].Sql
		$MYSQLDataAdapter.SelectCommand=$MYSQLCommand
		$NumberOfDataSets=$MYSQLDataAdapter.Fill($MYSQLDataSet, "data")

		# Remove the Existing Files if they exist
		$OutputFile | foreach {
			if (test-path $_\$($PlayLists[$i].File)) {
				write-output "Deleting Playlist File: $_\$($PlayLists[$i].File)"
				Remove-Item $_\$($PlayLists[$i].File)
			}
		}

		# Write the New Playlist
		foreach($DataSet in $MYSQLDataSet.tables[0]) {
			$OutputFile | foreach {
				if (test-path($_)) {
					$DataSet[0] | Out-File $_\$($PlayLists[$i].File) -append -encoding UTF8
				}
			}
		}
	}

	###############################################
	# Upload New Songs to Youtube
	Write-Output "Uploading songs to Youtube Music..."
    python ..\Python\UploadNewSongs.py

	###############################################
	# Create a link between YouTube Music songs and songs in the master database
	Write-Output "Create a link between YouTube Music songs and songs in the master database..."
	python ..\Python\LinkYouTubeMusicToDB.py

	###############################################
	# Update the youtube music playlists
	Write-Output "Uploading Youtube Music playlists if they need to be updated..."
	$Sql="select value from music.setting where setting = 'Reset Google Playlist'"
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()
	Write-Output "Update Google Playlist indicator: $($Setting)"
    if ($Setting -eq 'Y') {	
		python ..\Python\YouTubeMusicPlaylist.py

		# If there is an error running the python music updator we don't want
		# to reset the indicator which indicates that there is a pending music list update
		if ($LASTEXITCODE -eq 0) {
			# Reset update indicator
			$Sql="update music.setting set value='N', created_date = current_date(), created_by_id =  'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3'  where setting = 'Reset Google Playlist' "
			$MYSQLCommand.CommandText = $Sql
			$MYSQLCommand.ExecuteNonQuery()
		} else {
			Write-output "There was an error executing python"
		}
	}

#	$Connection.Close()

} catch {
	Write-Error $_
} finally {
	write-output "Done"
}