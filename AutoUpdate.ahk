#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

; Check the version of this script against the latest version available. If the
; latest version is greater than this version, prompt to download. If yes, then
; download the new AHK file, replace this one with the new version, and then 
; relaunch this script.

RunWait, 7z.exe,, Hide UseErrorLevel

if (ErrorLevel = 0)
	GoSub VersionCheck
else
	MsgBox, 7-zip not installed.  Automatic version update failed.
	
Return
	

VersionCheck:
	; Get update url and current version
	IniRead VersionURL,%IniLocation%,ScriptOptions,UpdateURL
	IniRead CurrentVersion,%IniLocation%,ScriptOptions,Version
	
	if (VersionURL = "ERROR" || CurrentVersion = "ERROR")
	{
		MsgBox, "Unable to read initialization settings. No version check performed."
	}
	
	; Get the latest version num from the server
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", VersionURL, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	
	LatestVersion := RegExReplace(SubStr(whr.ResponseText, 1, 10),"`n")
	
	if (ErrorLevel = 1 || !LatestVersion)
	{
		MsgBox, Failed to retrieve latest version number from `n%VersionURL%`nPlease check your network connection and try again.
		Return
	}
	else
	{
		match := compareVersions(LatestVersion,CurrentVersion)

		if (match != 0)
		{
			MsgBox, 52, , A newer version of this script is available. Do you want to Update and Reload the script?
			IfMsgBox Yes
				GoSub Update
			else
				Return
		}
		Return
	}
	Return

; We're here, so it must have been determined that a newer version exists.
; Download the LatestVersion.zip file, unzip it and overwrite any existing files.
Update:	
	; Download the LatestVersion zip file
	IniRead PackageURL,%IniLocation%,ScriptOptions,PackageURL
	URLDownloadToFile %PackageURL%%LatestVersion%.zip, %A_Temp%\%LatestVersion%.zip
	
	; 7z command
	CMD = e -y -o%A_ScriptDir% %A_Temp%\%LatestVersion%.zip
	
	RunWait 7z.exe %CMD%,, Hide UseErrorLevel
	
	if (ErrorLevel = 0)
	{
		Dir := StrSplit(a_scriptdir, "\")
		Dir := Dir.Pop()
		
		FileDelete %A_Temp%\%LatestVersion%.zip
		FileRemoveDir, %a_scriptdir%\%Dir%-%CurrentVersion%
		
		IniWrite, %LatestVersion%, %IniLocation%, ScriptOptions, Version
		
		MsgBox, Aethercraft.ahk has been updated.  It will now reload to the latest version.
		
		Reload
	} 
	else 
	{
		MsgBox An error occurred during the update process. No update was performed.
		Return
	}
	Return

	
; Compare software versions
;
; Compares software versions by splitting the software version string and
; comparing each digit seperately. If the remoteVersion substring is
; larger than the localVersion substring, the match variable is incremented.
;
; A return value of 0 means the versions are equal.
;
; Return	int	number of digits that are different between the local and 
;				remote version numbers
compareVersions(remoteVersion,localVersion)
{
	remoteArray := StrSplit(remoteVersion, ".")
	localArray := StrSplit(localVersion, ".")	
	match = 0
	
	Loop % remoteArray.Length()
	{
		this_r := remoteArray[A_Index]
		this_l := localArray[A_Index]
		
		if (this_r > this_l)
			++match
	}
	
	Return match
}
