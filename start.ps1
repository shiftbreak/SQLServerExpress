# The script sets the sa password and start the SQL Service 
# Also it attaches additional database from the disk
# The format for attach_dbs

param(
[Parameter(Mandatory=$false)]
[string]$sa_password

)



# start the service
Write-Verbose "Starting SQL Server"
start-service MSSQL`$SQLEXPRESS

Write-Verbose "Setting max RAM of 800MB"
sqlcmd -S 127.0.0.1 -Q "USE master; EXEC sp_configure 'show advanced options', 1;RECONFIGURE;EXEC sp_configure 'max server memory (MB)', 800; RECONFIGURE WITH OVERRIDE;EXEC sp_configure 'show advanced options', 0;"

if($sa_password -ne "_")
{
    Write-Verbose "Changing SA login credentials"
    $sqlcmd = "ALTER LOGIN sa with password='$sa_password';ALTER LOGIN sa ENABLE;"
    & sqlcmd -S 127.0.0.1 -Q $sqlcmd
}


Write-Verbose "Started SQL Server."


$lastCheck = (Get-Date).AddSeconds(-2) 
while ($true) 
{ 
    Get-EventLog -LogName Application -Source "MSSQL*" -After $lastCheck | Select-Object TimeGenerated, EntryType, Message   
    $lastCheck = Get-Date 
    Start-Sleep -Seconds 2 
}
