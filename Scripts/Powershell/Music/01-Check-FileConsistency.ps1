<#  
.SYNOPSIS  
    Check for file consistency
.DESCRIPTION  
    Checks for duplicate files, null album names and null song names in the Kodi database
	If any of these conditions are met the script must terminate
.LINK  
#>

Write-Output "****************************************************************************************************"
Write-Output "Checks for duplicate files, null album names and null song names in the Kodi database"
Write-Output "If any of these conditions are met the script must terminate"
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

} catch {
	Write-Error $_
} finally {
	Write-Output ""
}