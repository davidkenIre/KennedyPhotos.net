<#  
.SYNOPSIS  
    Generate Kody playlists  
.DESCRIPTION  
    This script generates Kodi playlists and writes them 
	directly to the playlist folder in Kodi
.LINK  
#>

###############################################
# GetValues from Registry
$LattuceRegKey=Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Lattuce

###############################################
# Keep the master song tables in sync with the Kody databases
[Reflection.Assembly]::LoadFile("c:\program files\Lattuce\Library.dll")
$Utility = new-object Music.Utility
$Utility.SyncMusicFromKodi()

###############################################
# Update the General playlists
Add-Type –Path 'c:\program files\Lattuce\MySql.Data.dll'
$Year=get-date -Format yyyy
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString=''}
$Connection.ConnectionString="server=$($LattuceRegKey.MySQLServer);uid=$($LattuceRegKey.MySQLUsername);pwd=$($LattuceRegKey.MySQLPassword);database=$($LattuceRegKey.KodiMusicSchema)"
$OutputFile = "\\10.10.1.9\Userdata\playlists\music", 
              "\\media-gym.lattuce.com\c$\Users\media\AppData\Roaming\Kodi\userdata\playlists\music",
              "d:\media\music\master\playlists",
              "\\10.10.1.24\Userdata\playlists\music" 

# Create a list of Playlists
$PlayLists = New-Object System.Collections.ArrayList

# Playlist 1
$PlayList = New-Object System.Object
$Sql = 'SELECT "#EXTM3U"
		UNION ALL
		SELECT CONCAT ("#EXTINF:", iDuration, ", ", strArtists, " - ", strTitle, char(13), char(10), p.strPath, s.strFileName )   
		FROM mymusic60.song s, mymusic60.path p
		where s.dateAdded is not null
		and s.dateAdded >= STR_TO_DATE(''01,01,' + $($Year) + ''',''%d,%m,%Y'')
		and s.idPath = p.idPath;'
$PlayList | Add-Member -MemberType NoteProperty -Name "Sql" -Value $Sql
$PlayList | Add-Member -MemberType NoteProperty -Name "File" -Value "Music Added in $($Year).m3u"
$PlayLists.Add($PlayList) | Out-Null

# Play List 2
# ...
# ...
# ...

# Open a database connection
$Connection.Open()
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet
$MYSQLCommand.Connection=$Connection

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
				$DataSet[0] | Out-File $_\$($PlayLists[$i].File) -append -encoding ASCII
			}
		}
	}
}
###############################################
# Update the google playlists
python ..\Python\GooglePlayPlaylists.py

write-output "Done"
$Connection.Close()