<#  
.SYNOPSIS  
    Upload new music files to Youtube music
.DESCRIPTION  
    Looks for records in the master music database which have not yet been linked to YouTube Music
	If it finds any, if simply uploads the file to YouTube Music.
	A subsequent step in this full process will link the newly uploaded file to the master database record
.LINK  
#>

Write-Output "****************************************************************************************************"
Write-Output "Looks for records in the master music database which have not yet been linked to YouTube Music"
Write-Output "If it finds any, if simply uploads the file to YouTube Music."
Write-Output "A subsequent step in this full process will link the newly uploaded file to the master database record"
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
	# Upload New Songs to Youtube
	Write-Output "Uploading songs to Youtube Music..."
    python UploadNewSongs.py



} catch {
	Write-Error $_
} finally {
	write-output ""
}