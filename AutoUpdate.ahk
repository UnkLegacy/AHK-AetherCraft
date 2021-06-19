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
	whr.Open("GET", VersionURL, true)
	whr.Send()
	; Using 'true' above and the call below allows the script to remain responsive.
	whr.WaitForResponse()
	
	latest := RegExReplace(SubStr(whr.ResponseText, 1, 10),"`n")
	Msgbox % latest
	latest := NumifyVersion(latest)
	MsgBox, EL = %ErrorLevel%`nlatest = %latest%`nCurrentVersion = %CurrentVersion%
	
	if (ErrorLevel = 1 || !latest)
	{
		MsgBox, Failed to retrieve latest version number from `n%VersionURL%`nPlease check your network connection and try again.
		Return
	}
	else
	{
		match := compareVersions(latest,CurrentVersion)
		if (match != 0)
		{
			MsgBox, A newer version of this script is available. After clicking OK, your script will be updated and relaunched.
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

NumifyVersion(version) {
	StringSplit, MyVersion, version, `.`

	Major := MyVersion1
	Minor := MyVersion2
	Fixlevel := MyVersion3
	BugfixlevelFull := MyVersion4

	Correction := 0
	Bugfixlevel := BugfixlevelFull

	if (RegExMatch(BugfixlevelFull, "i)RC")) {
		Bugfixlevel := RegExReplace(BugfixlevelFull, "i)RC","")
		Correction := -1
	}
	else if (RegExMatch(BugfixlevelFull, "i)BETA")) {
		Bugfixlevel := RegExReplace(BugfixlevelFull, "i)BETA","")
		Correction := -2
	}
	else if (RegExMatch(BugfixlevelFull, "i)ALPHA")) {
		Bugfixlevel := RegExReplace(BugfixlevelFull, "i)ALPHA","")
		Correction := -3
	}

	NumVersion := Major*1000000 + Minor*1000 + Fixlevel +Correction/10 + Bugfixlevel/10000
	return NumVersion

}