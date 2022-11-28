<#  
.SYNOPSIS  
    Log if internet is down
.DESCRIPTION  
    Log if internet is down	
.LINK  
#>

# Types
Add-Type –Path 'c:\program files\Lattuce\MySql.Data.dll'

# Constants
$UrlLight = "http://hue.lattuce.com/api/p3Gw2cnrtHOY-mo091kgYWvzhDv88sRS9DKDUhZx/lights/9/state"
$UrlPlug = "http://hue.lattuce.com/api/p3Gw2cnrtHOY-mo091kgYWvzhDv88sRS9DKDUhZx/lights/18/state"
$OnBodyJSON = @{"on" = $true}; $OnBodyJSON=$OnBodyJSON | ConvertTo-Json
$OffBodyJSON = @{"on" = $false}; $OffBodyJSON=$OffBodyJSON | ConvertTo-Json

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

	$CurrentStatus = "Up"
	if (Test-Connection 8.8.8.8 -Count 1 -ErrorAction SilentlyContinue) {$CurrentStatus="Up" } else {$CurrentStatus="Down"}             

	# Get the Max row
	# Was previous status up or down?
	$Sql = "select max(internet_downtime_id) from misc.internet_downtime"
	$MYSQLCommand.CommandText = $Sql
	$MaxInetnetDowntimeID=$MYSQLCommand.ExecuteScalar()

	# Was previous status up or down?
	$Sql = "select case when end_date is null then ""Down"" else ""Up"" end as status from misc.internet_downtime a "
	$Sql += "where a.internet_downtime_id = $($MaxInetnetDowntimeID) "
	$MYSQLCommand.CommandText = $Sql
	$LastStatus=$MYSQLCommand.ExecuteScalar()

	if ($CurrentStatus -ne $LastStatus) {
		if ($CurrentStatus -eq "Down") {
			# Internet has gone down
			$Sql = "insert into misc.internet_downtime (start_date, end_date) values (now(), NULL);"
			$MYSQLCommand.CommandText = $Sql
			$MYSQLCommand.ExecuteNonQuery()

			# Turn off router
			Invoke-RestMethod -Method 'Put' -Uri $UrlPlug -Body $OffBodyJSON

			# Flash Lights
			For ($i=0; $i -le 10; $i++) {
				Invoke-RestMethod -Method 'Put' -Uri $UrlLight -Body $OffBodyJSON
				Start-Sleep 1
				########
				Invoke-RestMethod -Method 'Put' -Uri $UrlLight -Body $OnBodyJSON
				Start-Sleep 1
			}

			# Turn on router
			Invoke-RestMethod -Method 'Put' -Uri $UrlPlug -Body $OnBodyJSON						
		} else {
			# Internet has come back
			$Sql = "update misc.internet_downtime a set end_date = now() "
			$Sql += "where a.internet_downtime_id = $($MaxInetnetDowntimeID) "
			$MYSQLCommand.CommandText = $Sql
			$MYSQLCommand.ExecuteNonQuery()
			
			# Flash Lights
			For ($i=0; $i -le 6; $i++) {
				Invoke-RestMethod -Method 'Put' -Uri $UrlLight -Body $OffBodyJSON
				Start-Sleep 3
				########
				Invoke-RestMethod -Method 'Put' -Uri $UrlLight -Body $OnBodyJSON
				Start-Sleep 3
			}			
		}
	}
	
} catch {
	Write-Error $_
} finally {
	write-output "Done"
}