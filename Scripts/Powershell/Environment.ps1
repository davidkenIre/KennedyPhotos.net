<#  
.SYNOPSIS  
    Log various environtmental readings, temperature, Humidity internally and externally
.DESCRIPTION  
.LINK  
#>

# Types
Add-Type –Path 'c:\program files\Lattuce\MySql.Data.dll'

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Constants
$OpenWeatherURL = "https://api.openweathermap.org/data/2.5/weather?lat=52.66353&lon=-8.53937&appid=329e4883702c93d258df080caaed1e2e&units=metric"
$UrlPlugHumidifier = "http://hue.lattuce.com/api/p3Gw2cnrtHOY-mo091kgYWvzhDv88sRS9DKDUhZx/lights/20/state"
$InteriorEmergencyHumidityLevel = 70
$InteriorHumidityTurnOnLevel = 60 
$InteriorHumidityTurnOffLevel = 55
$SleepingHours = @(20,21,22,23)
$OnBodyJSON = @{"on" = $true}; $OnBodyJSON=$OnBodyJSON | ConvertTo-Json
$OffBodyJSON = @{"on" = $false}; $OffBodyJSON=$OffBodyJSON | ConvertTo-Json

# GetValues from Registry
$LattuceRegKey=Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Lattuce

# Open a database connection
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString=''}
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet

# Get Authorisation
$postParams = @{email='davidken@live.ie';password="$($LattuceRegKey.SensorPushPassword)"}
$Response=Invoke-WebRequest -Uri https://api.sensorpush.com/api/v1/oauth/authorize -Method POST -Body $postParams

# Get AccessToken
$Response=Invoke-WebRequest -Uri https://api.sensorpush.com/api/v1/oauth/accesstoken -Method POST -Body $Response.Content
$AccessToken=$Response.Content | ConvertFrom-Json
$AccessToken=$AccessToken.accesstoken
$Header = @{
 "Accept"="application/json"
 "Authorization"="$($AccessToken)"
}


try {
	$Connection.ConnectionString="server=$($LattuceRegKey.MySQLServer);uid=$($LattuceRegKey.MySQLUsername);pwd=$($LattuceRegKey.MySQLPassword);database=$($LattuceRegKey.KodiMusicSchema)"
	$Connection.Open()
	$MYSQLCommand.Connection=$Connection

	# Get the external temperature
	$XML = Invoke-RestMethod -Method 'Get' -Uri $OpenWeatherURL
	$Sql = "insert into misc.environment_data (point_date, location, point_data_type, point_data) values (now(), '$($XML.name)', 'Temperature', $($XML.main.temp));"
	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteNonQuery()

	# Get the external humidity
	$Sql = "insert into misc.environment_data (point_date, location, point_data_type, point_data) values (now(), '$($XML.name)', 'Humidity', $($XML.main.humidity));"
	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteNonQuery()



	# Get Reading from Sensor - Study
	$Body= @{
    'sensors' = @('356231.14099784581718965593')
    'limit' = 1
        } | ConvertTo-Json
	$Response=(Invoke-WebRequest -Uri https://api.sensorpush.com/api/v1/samples -Method POST -Header $Header -Body $Body -ContentType 'application/json').Content
	$Response=$Response | ConvertFrom-Json

	$Reading = $Response.sensors."356231.14099784581718965593"
	Write-Output $Reading.observed
	Write-Output (($Reading.temperature - 32) * 5/9)  
	Write-Output $Reading.humidity

	# Get the humidity
	$Sql = "insert into misc.environment_data (point_date, location, point_data_type, point_data) values (str_to_date('" + $Reading.observed + "', '%Y-%m-%dT%H:%i:%s.000Z') + interval 1 hour, 'Study', 'Humidity', $($Reading.humidity));"
	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteNonQuery()

	# Get the temperature
	$Sql = "insert into misc.environment_data (point_date, location, point_data_type, point_data) values (str_to_date('" + $Reading.observed + "', '%Y-%m-%dT%H:%i:%s.000Z') + interval 1 hour, 'Study', 'Temperature', $(($Reading.temperature - 32) * 5/9));"
	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteNonQuery()

	# Get Reading from Sensor - Noel Bedroom
	$Body= @{
    'sensors' = @('361417.13909117624203411072')
    'limit' = 1
        } | ConvertTo-Json
	$Response=(Invoke-WebRequest -Uri https://api.sensorpush.com/api/v1/samples -Method POST -Header $Header -Body $Body -ContentType 'application/json').Content
	$Response=$Response | ConvertFrom-Json

	$Reading = $Response.sensors."361417.13909117624203411072"
	Write-Output $Reading.observed
	Write-Output (($Reading.temperature - 32) * 5/9)  
	Write-Output $Reading.humidity

	# Get the humidity
	$Sql = "insert into misc.environment_data (point_date, location, point_data_type, point_data) values (str_to_date('" + $Reading.observed + "', '%Y-%m-%dT%H:%i:%s.000Z') + interval 1 hour, 'Noel Bedroom', 'Humidity', $($Reading.humidity));"
	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteNonQuery()

	# Get the temperature
	$Sql = "insert into misc.environment_data (point_date, location, point_data_type, point_data) values (str_to_date('" + $Reading.observed + "', '%Y-%m-%dT%H:%i:%s.000Z') + interval 1 hour, 'Noel Bedroom', 'Temperature', $(($Reading.temperature - 32) * 5/9));"
	$MYSQLCommand.CommandText = $Sql
	$MYSQLCommand.ExecuteNonQuery()



	# Get the Max row
	$Sql = "select max(humidifier_events_id) from misc.humidifier_events"
	$MYSQLCommand.CommandText = $Sql
	$MaxHumififierEventsID=$MYSQLCommand.ExecuteScalar()

	# Was previous status up or down?
	$Sql = "select case when end_date is null then ""On"" else ""Off"" end as status from misc.humidifier_events a "
	$Sql += "where a.humidifier_events_id = $($MaxHumififierEventsID) "
	$MYSQLCommand.CommandText = $Sql
	$LastStatus=$MYSQLCommand.ExecuteScalar()

	$SwitchableOn = $false
	Write-Output("Noel Bedroom Humidity: $($Reading.humidity)")
	if ($Reading.humidity -gt $InteriorEmergencyHumidityLevel) {                  # Turn on at any time if RH > 70
		$SwitchableOn = $true
	} else {
		if ($Reading.humidity -gt $InteriorHumidityTurnOnLevel) {                   # Turn on if RH > 55 and not during sleeping hours
			if ((get-date).Hour -notin $SleepingHours) {
				$SwitchableOn = $true
			}
		}
	}
	Write-Output "Switchable On: $($SwitchableOn)"

	# Turn on Humidifier
	if (($SwitchableOn) -and ($LastStatus -eq "Off")) {
		Invoke-RestMethod -Method 'Put' -Uri $UrlPlugHumidifier -Body $OnBodyJSON

		$Sql = "insert into misc.humidifier_events (start_date, end_date) values (now(), NULL);"
		$MYSQLCommand.CommandText = $Sql
		$MYSQLCommand.ExecuteNonQuery()

		Start-Sleep 1
	}

	# Turn off Humidifier if it's currently on and (RH drops below 50 or it shouldnt be on because its sleeping hours) 
	if ((($Reading.humidity -lt $InteriorHumidityTurnOffLevel) -and ($LastStatus -eq "On")) -or $SwitchableOn -eq $false) {
		Invoke-RestMethod -Method 'Put' -Uri $UrlPlugHumidifier -Body $OffBodyJSON

		$Sql = "update misc.humidifier_events set end_date = now() where end_date is null;"
		$MYSQLCommand.CommandText = $Sql
		$MYSQLCommand.ExecuteNonQuery()

		Start-Sleep 1
	}
	

} catch {
	Write-Error $_
} finally {
	write-output "Done"
}






# List Sensors
#$Response=Invoke-WebRequest -Uri https://api.sensorpush.com/api/v1/devices/sensors -Method POST -Header $Header -Body ""
#$Sensors=$Response.Content | ConvertFrom-Json

#$c=0
#foreach ($Sensor in $Sensors) {
#	$c++
#	write-output $c
#}











#	# Get Reading from Sensor
#	$Now=Get-Date
#	$From=$Now.AddMinutes(-220); $From=$From.ToString("yyyy-MM-ddTHH:mm:ss+0100")
#	$To=$Now.AddMinutes(-60);  $To=$Now.ToString("yyyy-MM-ddTHH:mm:ss+0100")
#	$Body= @{
 #   'sensors' = @('356231.14099784581718965593')
  #  'limit' = 1
 #       } | ConvertTo-Json
#	$Response=(Invoke-WebRequest -Uri https://api.sensorpush.com/api/v1/samples -Method POST -Header $Header -Body $Body -ContentType 'application/json').Content
#	$Response=$Response | ConvertFrom-Json
