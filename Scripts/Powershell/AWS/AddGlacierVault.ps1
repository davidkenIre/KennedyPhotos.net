#
# AddGlacierVault.ps1
#

# Set the profile
Set-AWSCredential -ProfileName BackupProfile
Initialize-AWSDefaultConfiguration -ProfileName BackupProfile -Region eu-west-1

# Create a Vault
New-GLCVault -VaultName VAULT_NAME

# Upload Archives to a vault (ensure directory is clean and only contains .rar archives split into 4GB parts
cd c:\temp
Write-GLCArchive -VaultName VAULT_NAME -FolderPath .\ -Recurse | Export-Csv -Path "s:\Archives\Archive005.csv"
