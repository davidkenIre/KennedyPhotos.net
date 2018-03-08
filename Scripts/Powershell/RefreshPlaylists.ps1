<# .SYNOPSIS
     Refresh Master Music Library playlists
.DESCRIPTION
     Refresh Master Music Library playlists
.NOTES     
#>

[Reflection.Assembly]::LoadFile("c:\program files (x86)s\Lattuce\Library.dll")
$Utility = new-object Music.Utility

$Utility.SyncMusicFromKodi()

