#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

; Check the version of this script against the latest version available. If the
; latest version is greater than this version, prompt to download. If yes, then
; download the new AHK file, replace this one with the new version, and then 
; relaunch this script.

VersionCheck:
	; Get update url and current version
	IniRead VersionURL,%IniLocation%,ScriptOptions,UpdateURL
	IniRead CurrentVersion,%IniLocation%,ScriptOptions,Version
	
	if (VersionURL = "ERROR" || CurrentVersion = "ERROR")
	{
		MsgBox "Unable to read initialization settings. No version check performed."
	}
	
	; Get the latest version num from the server
	;URLDownloadToFile %VersionURL%, latestversion.txt
	;FileRead latest, latestversion.txt
	;latest := RegExReplace(latest,"`n")
	
	whr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
	whr.Open("GET", %VersionURL%, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	latest := whr.ResponseText
	
	if (ErrorLevel = 1)
	{
		MsgBox Failed to retrieve latest version number from %VersionURL%. Please check your network connection and try again.
		Return
	} 
	else
	{
		match := compareVersions(latest,CurrentVersion)
		if (match != 0)
		{
			MsgBox A newer version of this script is available. After clicking OK, your script will be updated and relaunched.
			GoSub Update
		}
		Return
	}
	Return

; We're here, so it must have been determined that a newer version exists.
; Download the latest.zip file, unzip it and overwrite any existing files.
Update:	
	; Download the latest zip file
	IniRead PackageURL,%IniLocation%,ScriptOptions,PackageURL
	URLDownloadToFile %PackageURL%, %A_Temp%\%CurrentVersion%.zip
	
	; 7z command
	CMD = e -y -o%A_ScriptDir% %A_Temp%\%CurrentVersion%.zip
	
	RunWait 7z.exe %CMD%,, Hide UseErrorLevel
	if (ErrorLevel = 0)
	{
		FileDelete %A_Temp%\%CurrentVersion%.zip
		Reload
	} 
	else 
	{
		MsgBox An error occurred during the update process. No update was performed.
		ExitApp
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
	StringSplit remoteArray, remoteVersion, "."
	StringSplit localArray, localVersion, "."
	match = 0
	
	Loop %remoteArray0%
	{
		this_r := remoteArray%A_Index%
		this_l := localArray%A_Index%
		if (this_r > this_l)
		{
			++match
		}
	}
	
	Return match
}
