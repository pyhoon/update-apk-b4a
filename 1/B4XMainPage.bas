B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
'#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region
'Ctrl + click to export as zip: ide://run?File=%B4X%\Zipper.jar&Args=1.zip

Sub Class_Globals
	Private Root As B4XView
	Private xui As XUI
	Private Phone As Phone
	Private Provider As FileProvider
	Private LblMessage As B4XView
	Private LblVersion As B4XView
	Private ServerUrl As String = "https://github.com/pyhoon/update-apk-b4a/blob/main/2/Objects"
	Private FileToInstall As String = "2.apk"
	Private latestVersion As Int = 2
	Private ion As Object
End Sub

Public Sub Initialize
'	B4XPages.GetManager.LogEvents = True
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("1")
	B4XPages.SetTitle(Me, "APP")
	LblVersion.Text = $"Version ${Application.VersionName}"$
	If Application.VersionCode = latestVersion Then
		LblMessage.Visible = False
	End If
	Provider.Initialize
End Sub

Private Sub BtnUpdate_Click
	If Application.VersionCode = latestVersion Then
		xui.MsgboxAsync("You already have the latest version", "")
		Return
	End If
	If File.Exists(File.DirInternal, FileToInstall) = False Then
		Log("Downloading updates from remote server...")
		Dim job As HttpJob
		job.Initialize("", Me)
		job.Download(ServerUrl & "/" & FileToInstall)
		Wait For (job) JobDone(job As HttpJob)
		If job.Success Then
			Dim out As OutputStream = File.OpenOutput(File.DirInternal, FileToInstall, False)
			File.Copy2(job.GetInputStream, out)
			out.Close '<------ very important
			Log("Download complete")
		Else
			Log("Error: " & job.ErrorMessage)
		End If
		job.Release
	End If
	SendInstallIntent
End Sub

Private Sub SendInstallIntent
	Dim i As Intent
	If Phone.SdkVersion >= 24 Then
		File.Copy(File.DirInternal, FileToInstall, Provider.SharedFolder, FileToInstall)
		i.Initialize("android.intent.action.INSTALL_PACKAGE", Provider.GetFileUri(FileToInstall))
		i.Flags = Bit.Or(i.Flags, 0x00000001) 'FLAG_GRANT_READ_URI_PERMISSION
	Else
		i.Initialize(i.ACTION_VIEW, "file://" & File.Combine(File.DirInternal, FileToInstall))
		i.SetType("application/vnd.android.package-archive")
	End If
	If Phone.SdkVersion >= 29 Then
		i.PutExtra("android.intent.extra.INSTALLER_PACKAGE_NAME", Application.PackageName)
	End If
	StartActivity(i)
End Sub

Public Sub StartActivityForResult (i As Intent)
	Dim jo As JavaObject = GetBA
	ion = jo.CreateEvent("anywheresoftware.b4a.IOnActivityResult", "ion", Null)
	jo.RunMethod("startActivityForResult", Array As Object(ion, i))
End Sub

Public Sub GetBA As Object
	Dim jo As JavaObject = Me
	Return jo.RunMethod("getBA", Null)
End Sub