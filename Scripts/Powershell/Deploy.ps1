<#  
.SYNOPSIS  
    Deploy Scripts to Server
.DESCRIPTION  
    
.LINK  
#>

# Rebuild Website
#if (test-path "S:\Websites\Lattuce") {remove-item S:\Websites\Lattuce -Recurse}
#& C:\WINDOWS\Microsoft.NET\Framework64\v4.0.30319\aspnet_compiler.exe -p C:\Data\GitHub\Lattuce\Web S:\Websites\Lattuce



# copy-item C:\Data\GitHub\Lattuce\Web \\lattuce-dc\data\Websites\Lattuce -verbose -Recurse
copy-item C:\Data\GitHub\Lattuce\Library\bin\Release\Library.dll \\lattuce-dc\data\scripts\Powershell

Copy-Item C:\data\github\Lattuce\Scripts\Powershell\*  \\lattuce-dc\data\scripts\Powershell -verbose
Copy-Item C:\data\github\Lattuce\Scripts\Python\*  \\lattuce-dc\data\scripts\Python -verbose
Copy-Item C:\Data\GitHub\Lattuce\Library\bin\Debug\*  '\\lattuce-dc\c$\Program Files\lattuce' -verbose


