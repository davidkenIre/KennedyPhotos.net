<#  
.SYNOPSIS  
    Generate Kody playlists  
.DESCRIPTION  
    This script generates Kodi playlists and writes them 
	directly to the playlist folder in Kodi
.LINK  
    YouTube Data API https://developers.google.com/youtube/v3/sample_requests
#>

try {
	.\01-Check-FileConsistency.ps1
	.\02-Sync-MusicKodiDB.ps1
	#.\03-Update-GeneralPlaylists.ps1  TODO Error in this file
	# .\04-Upload-NewFiles.ps1 TODO: Disabling this for the moment because its uploading files which are probably already uploaded
	.\05-Link-YTFilesToMaster.ps1
	.\06-Update-YTPlaylists.ps1
} catch {
	Write-Error $_
} finally {
	write-output "Music Script Run Complete..."
}