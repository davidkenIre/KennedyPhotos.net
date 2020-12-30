<#  
.SYNOPSIS  
    Update Youtube playlists
.DESCRIPTION  
    This script drops and recreates youtube playlists based on playlist information
	in the master music database, which is maintainced manually.
.LINK  
#>

Write-Output "****************************************************************************************************"
Write-Output "This script drops and recreates youtube playlists based on playlist information"
Write-Output "in the master music database, which is maintainced manually."
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
	# Update the youtube music playlists
	Write-Output "Uploading Youtube Music playlists if they need to be updated..."
	$Sql="select value from music.setting where setting = 'Reset Google Playlist'"
	$MYSQLCommand.CommandText = $Sql
	$Setting=$MYSQLCommand.ExecuteScalar()
	Write-Output "Update Google Playlist indicator: $($Setting)"
    if ($Setting -eq 'Y') {	
		python YouTubeMusicPlaylist.py

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

} catch {
	Write-Error $_
} finally {
	write-output ""
}