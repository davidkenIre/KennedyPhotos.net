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
$EmailTo1 = "davidken@live.ie"
$EmailTo2 = "michellekennedy1306@gmail.com"
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
$EndIndex=$HTML.IndexOf(' MB </TD>', $StaartIndex+1)

$Year = get-date -Format yyyy
$Month = get-date -Format MM
$Day = get-date -Format dd
$DaysInMonth = [DateTime]::DaysInMonth($Year, $Month)
$PercentageThroughMonth=[math]::Round((($Day/$DaysInMonth)*100),2)

$MBUsed=$($HTML.substring($StartIndex, $EndIndex-$StartIndex))
$GBUsedFormat='{0:N0}' -f [int]$MBUsed/1000
$MBUsedPercentage=[math]::Round($MBUsed/10000,2)

If (($MBUsed / 10000) -gt $PercentageThroughMonth) {$Warning="WARNING! "}
$Subject = "$($Warning)Eir Broadband usage for month: $($MBUsedPercentage)%"

$Body = "Eir Broadband Usage for the current month: $($MBUsedPercentage)% ($($GBUsedFormat)GB / 1,000GB) <br />Percentage through month: $($PercentageThroughMonth)%"
Send-MailMessage -To "$($EmailTo1)" -from "$($EmailFrom)" -Subject $Subject -SmtpServer $SmtpServer -UseSsl -Credential $Credentials -Body $Body -BodyAsHtml
