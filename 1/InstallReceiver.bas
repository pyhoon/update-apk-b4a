﻿B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Receiver
Version=13.1
@EndOfDesignText@
Sub Process_Globals
	
End Sub

'Called when an intent is received. 
'Do not assume that anything else, including the starter service, has run before this method.
Private Sub Receiver_Receive (FirstTime As Boolean, StartingIntent As Intent)
	Dim status As String = StartingIntent.GetExtra("android.content.pm.extra.STATUS")
	Log("Install status: " & status)
    
	If status = "0" Then
		Log("Install succeeded")
	Else
		Dim msg As String = StartingIntent.GetExtra("android.content.pm.extra.STATUS_MESSAGE")
		Log("Install failed: " & msg)
	End If

	StopService("")
End Sub