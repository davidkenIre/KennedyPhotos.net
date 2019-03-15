<#  
.SYNOPSIS  
    Deploy Scripts to Server
.DESCRIPTION  
    
.LINK  
#>

# Rebuild Website
#if (test-path "S:\Websites\Lattuce") {remove-item S:\Websites\Lattuce -Recurse}
#& C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -p C:\Data\GitHub\Lattuce\Web S:\Websites\Lattuce

sc.exe \\lattuce-dc stop PhotoWatcher

Write-Output "Library DLL" -Verbose
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\Library.dll \\lattuce-dc\data\scripts\Powershell
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\taglib-sharp.dll \\lattuce-dc\data\scripts\Powershell
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\policy.2.0.taglib-sharp.dll \\lattuce-dc\data\scripts\Powershell
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\policy.2.0.taglib-sharp.config \\lattuce-dc\data\scripts\Powershell

Write-Output "Scripts and Library DLL" -Verbose
Copy-Item C:\data\github\Lattuce\Scripts\Powershell\*  \\lattuce-dc\data\scripts\Powershell 
Copy-Item C:\data\github\Lattuce\Scripts\Python\*  \\lattuce-dc\data\scripts\Python 

Copy-Item C:\Data\GitHub\Lattuce\Library\bin\Debug\*  '\\lattuce-dc\c$\Program Files\lattuce' 

# Test Event Generator
Write-Output "Test Event Generator" -Verbose
Copy-Item C:\Data\GitHub\Lattuce\TestEventGenerator\bin\Debug\* '\\lattuce-dc\C$\Program Files (x86)\PhotoWatcher\' 


sc.exe \\lattuce-dc start PhotoWatcher
