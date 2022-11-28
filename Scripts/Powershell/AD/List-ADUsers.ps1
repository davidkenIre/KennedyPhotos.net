# Add-WindowsCapability -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0 -Online
$Users = Get-ADUser -Filter *
$Users

# User and manager
Get-ADUser -Filter { Enabled -eq $true } -Properties Title,Department,Manager -SearchScope Subtree | select Name, Title, Department, @{n="ManagerName";e={get-aduser $_.manager | select -ExpandProperty name}}, @{n="ManagerMail";e={get-aduser $_.manager -properties mail | select -ExpandProperty mail}}


One domain to another?
https://social.technet.microsoft.com/Forums/en-US/a077f7a9-1ec1-4d0d-9f0f-c4179334895f/powershell-getaduser-from-one-domain-to-a-trusted-domain-failed?forum=winserverpowershell