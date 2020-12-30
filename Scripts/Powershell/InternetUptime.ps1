<#  
.SYNOPSIS  
    Log if internet is down
.DESCRIPTION  
    Log if internet is down	
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

	$Status = "Up"

	$Sql = "insert into misc.internet_uptime (created_date, created_by, status) values ("
	$Sql += "curdate(), 'feb66d43-7615-4dbe-93f1-73cc4b4bf2a3', '$($Status)'"

	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteScalar()
} catch {
	Write-Error $_
} finally {
	write-output "Done"
}