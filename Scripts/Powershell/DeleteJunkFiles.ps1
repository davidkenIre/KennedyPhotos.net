<# .SYNOPSIS
     Delete Junk files
.DESCRIPTION
     Delete Junk files - for example, cache files added by MacOS
.NOTES     
#>

get-childitem d:\ -include .DS_Store -recurse | foreach ($_) {remove-item $_.fullname -force}