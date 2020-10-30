<#  
.SYNOPSIS  
    Find duplicate file based on hash value
.DESCRIPTION  
    
.LINK  
#>

# TODO
# Tidy write-output and email body to single variable


# Retrieve values from local windows registry specifically for emailing - These are values I don't want to keep in sourcecode!
$Reg = Get-ItemProperty -Path HKLM:\SOFTWARE\Lattuce
$EmailPassword = $Reg.EmailPassword
$EmailFrom = $Reg.EmailFrom
$EmailTo = $Reg.EmailTo
$AccessKey = $Reg.AWSAccessKey  # Using AWS for SMTP
$SecretKey = $Reg.AWSSecretKey  # Using AWS for SMTP
$SmtpServer = "email-smtp.eu-west-1.amazonaws.com"
$SecureKey = $(ConvertTo-SecureString -AsPlainText -String $SecretKey -Force)
$creds = $(New-Object System.Management.Automation.PSCredential ($AccessKey, $SecureKey))
$List = @{}
$DuplicatePhotos=""
$Directory = "d:\media\Photos"
$ExcludeDirectory = "d:\Media\Photos\Albums*"

write-output "Scanning directory: $($Directory) for duplicates<br />"
$DuplicatePhotos += "Scanning directory: $($Directory) for duplicates<br />"

try {
    $Files=get-childitem $Directory -recurse | where-object{$_.fullname -notlike $ExcludeDirectory}
    foreach ($File in $Files) {
        # Ignore Dirs   
        if (Test-Path -Path $File.FullName -PathType Leaf) {

            # Get the hash value
            $Hash=Get-FileHash $File.FullName
         
            $List.Add($Hash.Path,$Hash.Hash)            
        } # Ignore Dirs
    } # Each File

    $Groups=$List.GetEnumerator() | Group-Object Value | ? { $_.Count -gt 1 }
    write-output "Found $($Groups.Count) duplicate groups<br /><br />"
    $DuplicatePhotos += "Found $($Groups.Count) duplicate groups<br /><br />"
    ForEach ($Group in $Groups) {
        write-output "Group Name: $($Group.Name)<br />"
        write-output "Files in group:-<br />"
        write-output "$($Group.Group.Name)<br /><br />"

        $DuplicatePhotos += "Group Name: $($Group.Name)<br />"
        $DuplicatePhotos += "Files in group:-<br />"
        ForEach ($Dup in $Group.Group.Name){
            $DuplicatePhotos += """$($Dup)""<br />"
        }
        $DuplicatePhotos += "<hr /><br />"

    }
    if ($DuplicatePhotos -ne "") {
        Send-MailMessage -From $EmailFrom -To $EmailTo -Subject "Duplicate Photos" -Body $DuplicatePhotos -SmtpServer $SmtpServer -Credential $creds -UseSsl -Port 25 -BodyAsHtml
    }
} catch {
    Send-MailMessage -From $EmailFrom -To $EmailTo -Subject "Duplicate Photos" -Body "Error Running Duplicate Photos: $($_)" -SmtpServer $SmtpServer -Credential $creds -UseSsl -Port 25 -BodyAsHtml
}

