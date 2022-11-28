<#  
.SYNOPSIS  
    Move downloaded torrent downloads into media directories
.DESCRIPTION  
    This script runs on a fixed schedule, scanning for files downloaded by a torrent client.  It's makes a connection
    to thetvdb via its API's to get extra media information, it then places the files in an appropiate directory to be
    used by Kodi etc.  It sends a daily email detailing files processed (or files which could not be processed)

    Sample series.csv:-
    Name,Pattern,Path,SeriesID
	The Man In The High Castle,*The.Man.In.The.High.Castle*,d:\Media\Video\TV\The Man In The High Castle,295829
	The Walking Dead,*the.walking.dead*,d:\Media\Video\TV\The Walking Dead,153021

.LINK  
#>

Start-Sleep 60
Write-Output "$(get-date ): Starting PowerMove"

######################
# Types
Add-Type –Path 'c:\program files\Lattuce\MySql.Data.dll'

# GetValues from Registry
$LattuceRegKey=Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Lattuce

######################
# Pause Torrents 
Write-Output "$(get-date ): $(python PauseAllTorrents.py)"

######################
# Retrieve values from local windows registry specifically for emailing - These are values I don't want to keep in sourcecode!
$Reg = Get-ItemProperty -Path HKLM:\SOFTWARE\Lattuce
$EmailPassword = $Reg.EmailPassword
$EmailFrom = $Reg.EmailFrom
$EmailTo = $Reg.EmailTo
$AccessKey = $Reg.AWSAccessKey  # Using AWS for SMTP
$SecretKey = $Reg.AWSSecretKey  # Using AWS for SMTP
$SmtpServer = "email-smtp.eu-west-1.amazonaws.com"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $EmailFrom, $($EmailPassword | ConvertTo-SecureString -AsPlainText -Force) 
$SecureKey = $(ConvertTo-SecureString -AsPlainText -String $SecretKey -Force)
$creds = $(New-Object System.Management.Automation.PSCredential ($AccessKey, $SecureKey))
$MovieFilePath = $Reg.MovieFilePath
$LibreelecRootPwd = $Reg.LibreelecRootPwd
$FilesProcessed = ""
$Problems = $False

######################
# Retrieve values needed for the thtv.com scraper - I'm not really bothered about keeping these in sourcecode - the values are in the public domain anyway
#$SeriesFile = ((Split-Path $MyInvocation.MyCommand.Definition) + "\Series.csv")  # This csv file contains constants at the TV series level
#$Series = Import-Csv -Path $SeriesFile
$MirrorPath = "http://thetvdb.com"
$APIKey = "548120FC9A5EDEE3"

######################
# Local Directories
$Reg = Get-ItemProperty -Path HKLM:\SOFTWARE\Lattuce\PowerMove
$DownloadsDir = $Reg.DownloadsDir
$DestinationDir = $Reg.DestinationDir

######################
# Start Processing

# Open a database connection
$Connection = [MySql.Data.MySqlClient.MySqlConnection]@{ConnectionString=''}
$MYSQLCommand = New-Object MySql.Data.MySqlClient.MySqlCommand
$MYSQLDataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter
$MYSQLDataSet = New-Object System.Data.DataSet


$Files = Get-ChildItem $DownloadsDir -recurse | Where-Object {$_.Name -like "*.mkv" -or $_.Name -like "*.mp4" -or $_.Name -like "*.avi"}  # Find all media files dropped by torrent appliction

if ($Files.Count -gt 0) {

	$Connection.ConnectionString="server=$($LattuceRegKey.MySQLServer);uid=$($LattuceRegKey.MySQLUsername);pwd=$($LattuceRegKey.MySQLPassword);database=$($LattuceRegKey.KodiMusicSchema)"
	$Connection.Open()
	$MYSQLCommand.Connection=$Connection

	ForEach ($File in $Files) {
		$Season = ($File.Name -split ('S*(\d{1,2})(x|E)(\d{1,2})'))[1]
		$Episode = ($File.Name -split ('S*(\d{1,2})(x|E)(\d{1,2})'))[3]

		if ($Season -eq $null -and $Episode -eq $null) {
			# Movie
			Write-Output "$(Get-Date): Movie: $($File.Name)"
			Move-Item -literalpath "$($File.FullName)"  "$($MovieFilePath)" -force
			if (test-path "$($MovieFilePath)\$($File.Name)") {$FilesProcessed += "Moved $($File.FullName) to $($MovieFilePath)\$($File.Name)</br>"}
		} else {
			# TV Show
			Write-Output "$(Get-Date): TV Show: $($File.Name)"

			# Get a likely match from the database
			$FileName = $($file.name).Replace("'", "''")
			$Sql="select name, pattern, path, seriesid from misc.tvdb_link where instr('$FileName', pattern) > 0;"
			$MYSQLCommand.CommandText = $Sql
			$Setting=$MYSQLCommand.ExecuteReader()			

			If ($Setting.Read()) {
				$SeriesID=$($Setting.GetValue(3))
				$Path=$($Setting.GetValue(2))
				Write-Output "$(Get-Date): Matched file with Series ID: $($SeriesID)"
				Write-Output "$(Get-Date): Season: $($Season)  Episode: $($Episode)"
				
				$Season = ($File.Name -split ('S*(\d{1,2})(x|E)(\d{1,2})'))[1]
				$Episode = ($File.Name -split ('S*(\d{1,2})(x|E)(\d{1,2})'))[3]
				$EpisodesPath = ($MirrorPath + "/api/" + $APIKey + "/series/" + $SeriesID + "/all/en.xml")

				Try {
					$xml = [xml](Invoke-WebRequest -Uri $EpisodesPath | select-object -ExpandProperty Content -ErrorAction Stop)
				} Catch {
					$FilesProcessed += "Error querying TheTVDB for file: $($File.Name)</br>"
					Break
				}

 				$xml.Data.Episode | ForEach {
					If (($_.Combined_season -eq $Season.TrimStart('0')) -and ($_.EpisodeNumber -eq $Episode.TrimStart('0'))) {
                		new-item "$($Path)\Season $($Season)" -force -ItemType Directory
						$NewFilePath = "$($Path)\Season $($Season)\$($File.Name)"
						Move-Item -literalpath "$($File.FullName)"  "$($NewFilePath)" -force
						if (test-path $NewFilePath) {$FilesProcessed += "Moved $($File.FullName) to $NewFilePath</br>"}
					}
				}
			}
			$Setting.Close()
			$MYSQLCommand.Dispose()
		}
	}

	# Check for files which failed to move
	$Files = Get-ChildItem $DownloadsDir -recurse | Where-Object {$_.Name -like "*.mkv" -or $_.Name -like "*.mp4" -or $_.Name -like "*.avi"}
	ForEach ($File in $Files) {
		$FilesProcessed += "Could not move: $($File.FullName)</br>"
		$Problems = $True
	}

	######################
	# Delete Old Filess from downloaded directory
	if ($Problems -eq $False) {
		$limit = (Get-Date).AddDays(-60)

		# Delete files older than the $limit.
		Get-ChildItem -Path $DownloadsDir -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.LastWriteTime -lt $limit } | Remove-Item -Force

		# Delete any empty directories left behind after deleting the old files.
		Get-ChildItem -Path $DownloadsDir -Recurse -Force | Where-Object { $_.PSIsContainer -and (Get-ChildItem -Path $_.FullName -Recurse -Force | Where-Object { !$_.PSIsContainer }) -eq $null } | Remove-Item -Force -Recurse
	}

	######################
	# Call Kodi Video Update & Clean
	$Headers = @{
		'content-type' = 'application/json'
	}
	$BodyScan = @{
		"jsonrpc" = "2.0"
		"method" = "VideoLibrary.Scan"
		"id" = "mybash"
	} | ConvertTo-Json
	$BodyClean = @{
		"jsonrpc" = "2.0"
		"method" = "VideoLibrary.Clean"
		"id" = "mybash"
	} | ConvertTo-Json
	Invoke-RestMethod -Method Post -Body $BodyScan -Headers $Headers -Uri "http://root:$($LibreelecRootPwd)@media-sr.lattuce.com:80/jsonrpc"
	Invoke-RestMethod -Method Post -Body $BodyClean -Headers $Headers -Uri "http://root:$($LibreelecRootPwd)@media-sr.lattuce.com:80/jsonrpc"

	######################
	# Final Email
	if ($FilesProcessed -ne "") {Send-MailMessage -From $EmailFrom -To $EmailTo -Subject "Torrented File Move" -Body $FilesProcessed -SmtpServer $SmtpServer -Credential $creds -UseSsl -Port 25 -BodyAsHtml}
} # Files gt 0

######################
# Remove Completed torents and Resume

Write-Output "$(get-date ): $(python RemoveCompletedTorrents.py)"

Write-Output "$(get-date ): Finishing PowerMove"
Write-Output "======================================================"