<# .SYNOPSIS
     Delete Archives from a Glacier Vault
.DESCRIPTION
     Submit job to create a list of archives
	 Delete archives in a loop
.NOTES     
#>

$AccountId="138752486395"
$VaultName="LattuceData2020"
$Region="eu-west-1"

# Get archives associated with a vault - This kicks off a job...
aws glacier initiate-job --job-parameters "{""Type"": ""inventory-retrieval""}" --account-id $AccountId --region $Region --vault-name $VaultName

# Status of job
aws glacier list-jobs --account-id $AccountId --region $Region --vault-name $VaultName 

# Output Job to a text file - this file contains the archives in a vault
aws glacier get-job-output --account-id $AccountId --region $Region --vault-name $VaultName --job-id FROM_PREV_COMMAND ./OutputFile.json

$json = Get-Content -Raw .\OutputFile.json
$Glacier=$json | ConvertFrom-Json
$ArchiveList=$Glacier.ArchiveList

foreach ($ArchiveId in $ArchiveList.ArchiveId) {
	$Count++
	write-output "Deleting Archive ID: $($ArchiveId) ($($Count) of $($ArchiveList.ArchiveId.Count))"
	aws glacier delete-archive --archive-id=$($ArchiveId) --vault-name $VaultName --account-id $($AccountId) --region $Region
}

		
