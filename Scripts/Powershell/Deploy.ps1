<#  
.SYNOPSIS  
    Deploy Scripts to Server
.DESCRIPTION  
    
.LINK  
#>

# Rebuild Website
#if (test-path "S:\Websites\Lattuce") {remove-item S:\Websites\Lattuce -Recurse}
#& C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -p C:\Data\GitHub\Lattuce\Web S:\Websites\Lattuce

Write-Output "Copying scripts and DLLs" -Verbose
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\Library.dll \\lattuce-dc\data\scripts\Powershell -force
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\taglib-sharp.dll \\lattuce-dc\data\scripts\Powershell -force
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\policy.2.0.taglib-sharp.dll \\lattuce-dc\data\scripts\Powershell -force
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\policy.2.0.taglib-sharp.config \\lattuce-dc\data\scripts\Powershell -force
Copy-Item C:\data\github\Lattuce\Scripts\Powershell\*  \\lattuce-dc\data\scripts\Powershell -Recurse -force
Copy-Item C:\data\github\Lattuce\Scripts\Python\*  \\lattuce-dc\data\scripts\Python -Recurse -force

Copy-Item C:\Data\GitHub\Lattuce\Library\bin\Debug\*  '\\lattuce-dc\c$\Program Files\lattuce'  -force

# Test Event Generator
Write-Output "Test Event Generator" -Verbose
sc.exe \\lattuce-dc stop PhotoWatcher
Copy-Item C:\Data\GitHub\Lattuce\TestEventGenerator\bin\Debug\* '\\lattuce-dc\C$\Program Files (x86)\PhotoWatcher\' -force
sc.exe \\lattuce-dc start PhotoWatcher