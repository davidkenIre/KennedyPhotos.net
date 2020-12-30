<#  
.SYNOPSIS  
    Sync Kodi Music Database to Master Music Database
.DESCRIPTION  
    Kodi reads the filesystem everynight and syncs new music to its own internal database
	This script then synchronises the Kodi music database to the master music database
.LINK  
#>

Write-Output "****************************************************************************************************"
Write-Output "Kodi reads the filesystem everynight and syncs new music to its own internal database"
Write-Output "This script then synchronises the Kodi music database to the master music database"
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

} catch {
	Write-Error $_
} finally {
	write-output ""
}