<#  
.SYNOPSIS  
    Update General Playlists
.DESCRIPTION  
    This script creates general music playlists (.m3u files) from manually maintained playlists
	and places them on various servers and music player devices
.LINK  
#>


Write-Output "****************************************************************************************************"
Write-Output "This script creates general music playlists (.m3u files) from manually maintained playlists"
Write-Output "and places them on various servers and music player devices"
Write-Output "****************************************************************************************************"

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
					write-output "Creating Playlist File: $_\$($PlayLists[$i].File)"
					$DataSet[0] | Out-File $_\$($PlayLists[$i].File) -append -encoding UTF8
				}
			}
		}
	}


} catch {
	Write-Error $_
} finally {
	write-output ""
}