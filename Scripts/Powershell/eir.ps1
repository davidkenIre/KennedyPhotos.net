<#  
.SYNOPSIS  
    Email Eir usage statistics
.DESCRIPTION  
    
.LINK  
#>

Param(
  [Parameter(Mandatory=$True)][string]$EmailPassword,
  [Parameter(Mandatory=$True)][string]$EirUsername,
  [Parameter(Mandatory=$True)][string]$EirPassword,
  [Parameter(Mandatory=$True)][string]$SmtpServer
)

$EmailFrom = "davidken@live.ie"
$EmailTo = "davidken@live.ie"
$Credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $EmailFrom, $($EmailPassword | ConvertTo-SecureString -AsPlainText -Force) 
    

$Response = Invoke-WebRequest -Uri "http://dslstats.eir.ie/commoncgi/dslstats/showstats.cgi?username=$($EirUsername)&password=$($EirPassword)" -method get
$HTML=$Response.Content
$LastIndex=$HTML.IndexOf('Combined Usage')
for ($Count=0; $Count -lt 3; $Count++) {
	$LastIndex=$HTML.IndexOf('<TD ALIGN=RIGHT>', $LastIndex+1)
	#write-output $LastIndex
}
$LastIndex=$LastIndex+3

$StartIndex=$LastIndex+13
$EndIndex=$HTML.IndexOf(' MB </TD>', $StartIndex+1)

$Year = get-date -Format yyyy
$Month = get-date -Format MM
$Day = get-date -Format dd
$DaysInMonth = [DateTime]::DaysInMonth($Year, $Month)
$PercentageThroughMonth=($Day/$DaysInMonth)*100

$GBUsed=$($HTML.substring($StartIndex, $EndIndex-$StartIndex))
$GBUsedFormat='{0:N0}' -f [int]$GBUsed
$Subject = "Eir Broadband Usage for month: $($GBUsed / 10000)%"

$Body = "Eir Broadband Usage for the current month: $($GBUsedFormat)GB / 1,000,000GB`nPercentage through month: $($PercentageThroughMonth)%"
Send-MailMessage -To "$($EmailTo)" -from "$($EmailFrom)" -Subject $Subject -SmtpServer $SmtpServer -UseSsl -Credential $Credentials -Body $Body
