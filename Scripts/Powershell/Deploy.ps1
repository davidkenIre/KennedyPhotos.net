<#  
.SYNOPSIS  
    Deploy Scripts to Server
.DESCRIPTION  
    
.LINK  
#>

# Rebuild Website
remove-item S:\Websites\Lattuce -Recurse
& C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -v / -p C:\Data\GitHub\Lattuce\Web\obj\Release\AspnetCompileMerge\Source -u S:\Websites\Lattuce

Copy-Item C:\data\github\Lattuce\Scripts\Powershell\*  \\lattuce-dc\data\scripts\Powershell -verbose
Copy-Item C:\data\github\Lattuce\Scripts\Python\*  \\lattuce-dc\data\scripts\Python -verbose
Copy-Item C:\Data\GitHub\Lattuce\Library\bin\Debug\*  '\\lattuce-dc\c$\Program Files\lattuce' -verbose


