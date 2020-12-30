<#  
.SYNOPSIS  
    Link Youtube files to master database
.DESCRIPTION  
    This script pulls down a listing of all files uploaded to the youtube database
	It then matches the list to the master database and addes a Youtube Id to each song 
	matched.
.LINK  
#>

Write-Output "****************************************************************************************************"
Write-Output "This script pulls down a listing of all files uploaded to the youtube database"
Write-Output "It then matches the list to the master database and addes a Youtube Id to each song "
Write-Output "matched."
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
	

	###############################################
	# Create a link between YouTube Music songs and songs in the master database
	Write-Output "Create a link between YouTube Music songs and songs in the master database..."
	python LinkYouTubeMusicToDB.py

} catch {
	Write-Error $_
} finally {
	write-output ""
}