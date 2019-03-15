#
# DeleteGlacierVault.ps1
#

# Get archives associated with a vault - This kicks off a job...
aws glacier initiate-job --job-parameters "{""Type"": ""inventory-retrieval""}" --account-id ACCOUNT_ID --region REGION --vault-name VAULT_NAME

# Status of job
aws glacier list-jobs --account-id ACCOUNT_ID --region REGION --vault-name VAULT_NAME 

# Output Job to a text file - this file contains the archives in a vault
aws glacier get-job-output --account-id ACCOUNT_ID --region REGION --vault-name VAULT_NAME --job-id FROM_PREV_COMMAND ./OutputFile.json



# Run through the vault and delete archives in turn
# helper to turn PSCustomObject into a list of key/value pairs
function Get-ObjectMembers {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, ValueFromPipeline=$True)]
        [PSCustomObject]$obj
    )
    $obj | Get-Member -MemberType NoteProperty | ForEach-Object {
        $key = $_.Name
        [PSCustomObject]@{Key = $key; Value = $obj."$key"}
    }
}

$json = Get-Content -Raw .\output_LattuceBackup.json
$Glacier=$json | ConvertFrom-Json
$ArchiveList=$Glacier.ArchiveList

foreach ($ArchiveId in $ArchiveList.ArchiveId) {
	$Count++
	write-output "Deleting Archive ID: $($ArchiveId) ($($Count) of $($ArchiveList.ArchiveId.Count)"
	aws glacier delete-archive --archive-id=$($ArchiveId) --vault-name VAULT_NAME --account-id ACCOUNT_ID --region REGION
}

		
