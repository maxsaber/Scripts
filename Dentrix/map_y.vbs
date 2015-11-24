Dim objNetwork, strLocalDrive, strRemoteShare
Set objNetwork = WScript.CreateObject("WScript.Network")
strLocalDrive = "Y:"
strRemoteShare = "\\dx\dximage" 
persistent = True
objNetwork.MapNetworkDrive strLocalDrive, strRemoteShare, False