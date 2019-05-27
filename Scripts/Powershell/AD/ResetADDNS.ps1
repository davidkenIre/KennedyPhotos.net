#
# ResetADDNS.ps1
#

ipconfig /flushdns
ipconfig /registerdns 
net stop netlogon 
net start netlogon 