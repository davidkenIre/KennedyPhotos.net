<# .SYNOPSIS
     Reset the system time from a timeserver
.DESCRIPTION
     Reset the system time from a timeserver
.NOTES     
#>

net stop w32time
w32tm /config /syncfromflags:manual /manualpeerlist:"time.windows.com"
w32tm /config /reliable:yes
net start w32time