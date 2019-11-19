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
$FilesProcessed = ""

######################
# Retrieve values needed for the thtv.com scraper - I'm not really bothered about keeping these in sourcecode - the values are in the public domain anyway
$SeriesFile = ((Split-Path $MyInvocation.MyCommand.Definition) + "\Series.csv")  # This csv file contains constants at the TV series level
$Series = Import-Csv -Path $SeriesFile
$MirrorPath = "http://thetvdb.com"
$APIKey = "548120FC9A5EDEE3"

######################
# Local Directories
$Reg = Get-ItemProperty -Path HKLM:\SOFTWARE\Lattuce\PowerMove
$DownloadsDir = $Reg.DownloadsDir
$DestinationDir = $Reg.DestinationDir

######################
# Start Processing
$Files = Get-ChildItem $DownloadsDir -recurse | Where-Object {$_.Name -like "*.mkv" -or $_.Name -like "*.mp4" -or $_.Name -like "*.avi"}  # Find all media files dropped by torrent appliction

ForEach ($File in $Files) {
    ForEach ($Serie in $Series) {
        If ($File.Name -like $Serie.Pattern) {
            $Season = ($File.Name -split ('S*(\d{1,2})(x|E)(\d{1,2})'))[1]
            $Episode = ($File.Name -split ('S*(\d{1,2})(x|E)(\d{1,2})'))[3]
            $EpisodesPath = ($MirrorPath + "/api/" + $APIKey + "/series/" + $Serie.SeriesID + "/all/en.xml")

            Try {
                $xml = [xml](Invoke-WebRequest -Uri $EpisodesPath | select-object -ExpandProperty Content -ErrorAction Stop)
            } Catch {
                $FilesProcessed += "Error querying TheTVDB for file: $($File.Name)</br>"
                Break
            }

 			$xml.Data.Episode | ForEach {
                If (($_.Combined_season -eq $Season.TrimStart('0')) -and ($_.EpisodeNumber -eq $Episode.TrimStart('0'))) {
                	new-item "$($Serie.Path)\Season $($Season)" -force -ItemType Directory

                    # $NewFilePath = ($Serie.Path) + "\" + ($Serie.Name + " - " + "S" + $Season + "E" + $Episode + " - " + (     ((((($_.EpisodeName) -replace "\?", "") -replace "`"","'") -replace " / ",", ") -replace "/",", ") -replace ":"," -"     ) + $File.Extension)
                    $NewFilePath = "$($Serie.Path)\Season $($Season)\$($File.Name)"

	                Move-Item -literalpath "$($File.FullName)"  "$($NewFilePath)" -force
	                if (test-path $NewFilePath) {$FilesProcessed += "Moved $($File.FullName) to $NewFilePath</br>"}
                }
            }
        }
    }
}

# Check for files which failed to move
$Files = Get-ChildItem $DownloadsDir -recurse | Where-Object {$_.Name -like "*.mkv" -or $_.Name -like "*.mp4" -or $_.Name -like "*.avi"}
ForEach ($File in $Files) {
    $FilesProcessed += "Could not move: $($File.FullName)</br>"
}

######################
# Final Email
if ($FilesProcessed -ne "") {Send-MailMessage -From $EmailFrom -To $EmailTo -Subject "Torrented File Move" -Body $FilesProcessed -SmtpServer $SmtpServer -Credential $creds -UseSsl -Port 25 -BodyAsHtml}