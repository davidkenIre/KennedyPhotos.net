<#  
.SYNOPSIS  
    Backup MySQL
.DESCRIPTION  
    Backs up MySQL to a timestamped file
.LINK  
#>

###############################################
# GetValues from Registry
$LattuceRegKey=Get-ItemProperty -Path Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Lattuce
$ProgramPath="C:\Program Files\MySQL\MySQL Server 5.5\bin"
$BackupPath="d:\Backups\MySQL"

$dateStr = get-date -format "yyyMMddHHmmss"
& "$($ProgramPath)\mysqldump.exe" --user=$($LattuceRegKey.MySQLUsername) --password=$($LattuceRegKey.MySQLPassword)  --host=localhost --port=3306 --result-file="$($BackupPath)\backup.$($DateStr).sql" --default-character-set=utf8 --single-transaction=TRUE --all-databases --events

###############################################
# Delete old backups
$limit = (Get-Date).AddDays(-30)

# Delete files older than the $limit.
Get-ChildItem -Path $BackupPath -Recurse -Force | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
