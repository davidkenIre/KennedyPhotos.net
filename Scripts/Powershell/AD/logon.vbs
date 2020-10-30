Option Explicit

On Error Resume Next

Dim WshNetwork, DriveToRename, oShell

Set WshNetwork = WScript.CreateObject("WScript.Network")
WshNetwork.MapNetworkDrive "S:", "\\10.10.1.1\data", true
WshNetwork.MapNetworkDrive "M:", "\\10.10.1.1\media", true

' Rename the Drives
Set oShell = CreateObject("Shell.Application")
DriveToRename = "s:"
oShell.NameSpace(DriveToRename).Self.Name = "Data"

DriveToRename = "m:"
oShell.NameSpace(DriveToRename).Self.Name = "Media"

DriveToRename = "u:"
oShell.NameSpace(DriveToRename).Self.Name = "User"