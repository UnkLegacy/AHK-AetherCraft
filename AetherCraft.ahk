﻿; Originally created by Staren Alloria.
; Improvements by Lovo'tan Khatshri.

#Persistent ; Keeps script permanently running
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force ; Ensures that there is only a single instance of this script running.
#InstallKeybdHook
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

IniLocation = %A_ScriptDir%\AetherCraft.ini

; These are to tell the AutoUpdater where the Script lives to update it.
; These should not be your personal Github information (unless you forked the repo)
GitHub_User := "UnkLegacy"
GitHub_Repo := "AHK-AetherCraft"

GoSub CreateIfNoExist

if AutoUpdate
	{
	#include %A_ScriptDir%\AutoUpdate.ahk
	}

; Table of Contents:
; 1. Ctrl + S or Ctrl + R - Reload Script.  Only works in NotePad++.
; 2. Ctrl + Alt + H - Shows the ReadMe file.
; 3. F6  - Scan Market Board.  Ensure the Hand is showing on the first item before hitting F6.
; 3. F10 - Launch Craft GUI.
; 4. F12 - Stop Any Script.

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

#If (WinActive("ahk_class Notepad++") && WinActive("ahk_exe Notepad++.exe"))
 
~^s::
^r::
; Ctrl+S OR Ctrl+R - Saves and reloads script.
TrayTip, Reloading updated script, %A_ScriptName%
SetTimer, RemoveTrayTip, 1500
Sleep, 1750
Reload
Return
 
#If

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

^!h::
; Ctrl+Alt+h - Show Help (the Readme file)
FileRead, Readme, %A_ScriptDir%\Readme.md
Gui, Add, Text,, %Readme%
Gui, Show
Return

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

f6::
; F6 - Market Board Scan
GoSub ReadIni
Gui, Add, Text,, Total Items (Blank = 100):	; Label for total items
Gui, Add, Edit, w75 vTotal ym  ; The ym option starts a new column of controls.
Gui, Add, Button, gScan, &Scan ; The function Scan will be run when the Scan button is pressed.
Gui, Show,, Macro Settings
Return

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

Scan:
	Gui, Submit  ; Save the input from the user to each control's associated variable.
	
	; Variables
	Delay = 500 ; in milliseconds, increase this number to go slower.
	Looping = 0
	Done = 0
	Breakloop := false
	
	; Let user know the script is starting
	WinActivate, %GameTitle%
	Sleep, Delay
	Send, /
	Sleep, Delay * .5
	Send, echo Scanning by AHK started. <se.13> {enter}
	Sleep, Delay
	
	Loop, %Total% ; Main loop to scan Market Board
	{
	; Check for user to break
	If Breakloop
		Break
	; ControlSend, Parent of Window, {Button to Send}, Actual Window to Send to
	ControlSend, %AHKParent%, {%Confirm%}, %Game% ; Enter into the Item Detail
	Sleep, Delay
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%goUp%}, %Game% ; Go up in item Window, Step 1 of 2
	Sleep, Delay
	If Breakloop
		Break		
	ControlSend, %AHKParent%, {%goRight%}, %Game% ; Go right in item Window, Step 2 of 2
	Sleep, Delay
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%Confirm%}, %Game% ; Open Item History
	Sleep, Delay
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%goEsc%}, %Game% ; Leave Item History
	Sleep, Delay
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%goEsc%}, %Game% ; Leave Item
	Sleep, Delay
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%goDown%}, %Game% ; Go to Next Item
	Sleep, Delay
	
	Looping++
	Done++
	
	If (Looping = 100)
		{
		Looping = 0
		If Breakloop
		Break
		ControlSend, %AHKParent%, {%goRight%}, %Game% ; Highlight Display next 100 results
		Sleep, Delay
		If Breakloop
		Break
		ControlSend, %AHKParent%, {%Confirm%}, %Game% ; Click next page
		Sleep, Delay * 4 ; Wait a long time for the page to load
		If Breakloop
		Break
		ControlSend, %AHKParent%, {%goDown%}, %Game% ; Go to top of window
		Sleep, Delay
		If Breakloop
		Break
		ControlSend, %AHKParent%, {%goDown%}, %Game% ; Go to Next Item
		Sleep, Delay
		}
	}
	
	Remaining := Total - Done
	
	; Let user know the script is finished
	WinActivate, %GameTitle%
	Sleep, Delay
	Send, /
	Sleep, Delay * .5
	If (Breakloop)
		Send, echo Scanning stopped by user. %Done% of %Total% scanned. %Remaining% remaining.<se.11>
	Else
		Send, echo Scanning by AHK completed. <se.1>
	Send, {enter}
	
Gui, Destroy
Return

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

f10::
; F10 - Auto Craft
GoSub ReadIni
Gui, Add, Text,, Total Crafts:	; Label for total crafts
Gui, Add, Text,, Macro Duration(sec):	; Label for how long macro takes to run
Gui, Add, Text,, Macro button (eg, Numpad1):  ; Label for which button the crafting macro resides on
Gui, Add, Edit, w75 vTotal ym, %craftTotal%  ; The ym option starts a new column of controls.
Gui, Add, Edit, w75 vTime, %craftTime% ; Time, in seconds to craft once.
Gui, Add, Edit, w75 vMacroButton, %craftButton% ; Macro button
Gui, Add, Button, gCraft, &Craft ; The function Craft will be run when the Craft button is pressed.
Gui, Show,, Macro Settings
Return

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

Craft:
	Gui, Submit  ; Save the input from the user to each control's associated variable.
	
	; Write user settings back to ini file.  Only if they changed.
	If (Total != craftTotal)
		IniWrite, "%Total%", %IniLocation%, LastCraft, CraftTotal
	If (Time != craftTime)
		IniWrite, "%Time%", %IniLocation%, LastCraft, CraftTime
	If (MacroButton != craftButton)
		IniWrite, "%MacroButton%", %IniLocation%, LastCraft, CraftMacroButton
	
	; Variables
	SleepTime := (Time * 1000) + 1000 ; Add 1 second to macro time
	
	; Estimate Completion Time
	totalDelayTime := (Delay * 2) + SleepTime + (Delay * fastDelay) ;// Total time for 1 loop of not first or last item
	totalTime := (totalDelayTime * (Total - 1)) + (Delay * slowDelay) + (SleepTime - 3000) ;// Add first craft slowness and last craft fastness
	totalCraftTimeMinutes := Floor((totalTime / 1000) / 60)
	totalCraftTimeSeconds := Round(Mod((totalTime / 1000),60))
	
	Breakloop := false
	Done = 0
	
	; Let user know the script is starting
	WinActivate, %GameTitle%
	Sleep, Delay
	Send, /
	Sleep, Delay * quickDelay
	Send, echo Crafting by AHK started. Complete ETA: %totalCraftTimeMinutes%m %totalCraftTimeSeconds%s <se.13>{enter}
	Sleep, Delay
	
	Loop, %Total%
	{
	; Check for user to break
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%Confirm%}, %Game% ; Select the recipe
	Sleep, Delay
	ControlSend, %AHKParent%, {%Confirm%}, %Game% ; Hit Synthesize
	Sleep, Delay
	ControlSend, %AHKParent%, {%Confirm%}, %Game% ; Starts crafting
	
	if (A_Index = 1)
		Sleep, Delay * slowDelay ; Wait for us to sit down
	else
		Sleep, Delay * fastDelay ; or dont
	
	If Breakloop
		Break
	ControlSend, %AHKParent%, {%MacroButton%}, %Game% ; Hit your crafting macro button
	If Breakloop
		Break
		
	Done++ ; +1 item done, yay
	
	If (Total = A_Index)
		Sleep, SleepTime - 3000 ; No need to wait if this is the last item we're crafting.
	else
		Sleep, SleepTime ; Wait for crafting macro to finish
	}
	
	; Let user know the script is finished
	WinActivate, %GameTitle%
	Sleep, Delay
	Send, /
	Sleep, Delay * quickDelay
	If (Breakloop)
		{
		Send, echo Crafting stopped by user. %Done% of %Total% complete. <se.11>{enter}
		Sleep, Delay * quickenDelay
		Total := Total - Done
		IniWrite, "%Total%", %IniLocation%, LastCraft, CraftTotal ; Update amount to craft to what was left when interrupted
		}
	Else
		Send, echo Crafting by AHK completed. <se.1>{enter}
	
Gui, Destroy
Return

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

f12::
; F12 - Breaks the automation loops
Breakloop := true
TrayTip,, Stopping... Please wait. ,, 18
Return

; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Removes any popped up tray tips.
RemoveTrayTip:
	SetTimer, RemoveTrayTip, Off 
	TrayTip 
	Return 
	
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////

; Closes windows properly
GuiClose:
	Gui, Destroy
	Return
	
; ////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
; Read the Ini file for updated settings
ReadIni:
	IniRead, AHKParent, %IniLocation%, GameLocation, AHKParent
	IniRead, Game, %IniLocation%, GameLocation, Game
	IniRead, GameTitle, %IniLocation%, GameLocation, GameTitle

	IniRead, goUp, %IniLocation%, StaticUserSettings, UpButton
	IniRead, goRight, %IniLocation%, StaticUserSettings, RightButton
	IniRead, goDown, %IniLocation%, StaticUserSettings, DownButton
	IniRead, goEsc, %IniLocation%, StaticUserSettings, EscButton
	IniRead, Confirm, %IniLocation%, StaticUserSettings, ConfirmButton
	
	IniRead, craftTotal, %IniLocation%, LastCraft, CraftTotal
	IniRead, craftTime, %IniLocation%, LastCraft, CraftTime
	IniRead, craftButton, %IniLocation%, LastCraft, CraftMacroButton
	
	IniRead, Delay, %IniLocation%, DelaySettings, Delay
	IniRead, quickDelay, %IniLocation%, DelaySettings, TextInputDelay
	IniRead, fastDelay, %IniLocation%, DelaySettings, MultiCraftDelay
	IniRead, slowDelay, %IniLocation%, DelaySettings, SitDownDelay
	
	Return
	
CreateIfNoExist:
	IniRead, VersionURL, %IniLocation%, ScriptOptions, UpdateURL, "NoURL"
	IniRead, Delay, %IniLocation%, DelaySettings, Delay, "NoDelay"
	IniRead, AutoUpdate, %IniLocation%, ScriptOptions, AutoUpdate, 1

	If !FileExist("AetherCraft.ini")
	{
		IniWrite, "ahk_parent", %IniLocation%, GameLocation, AHKParent
		IniWrite, "ahk_exe ffxiv_dx11.exe", %IniLocation%, GameLocation, Game
		; IniWrite, "ahk_class FFXIVGAME", %IniLocation%, GameLocation, Game
		IniWrite, "FINAL FANTASY XIV", %IniLocation%, GameLocation, GameTitle

		IniWrite, "Up", %IniLocation%, StaticUserSettings, UpButton
		IniWrite, "Right", %IniLocation%, StaticUserSettings, RightButton
		IniWrite, "Down", %IniLocation%, StaticUserSettings, DownButton
		IniWrite, "Esc", %IniLocation%, StaticUserSettings, EscButton
		IniWrite, "Numpad0", %IniLocation%, StaticUserSettings, ConfirmButton

		IniWrite, "2", %IniLocation%, LastCraft, CraftTotal
		IniWrite, "25", %IniLocation%, LastCraft, CraftTime
		IniWrite, "Numpad1", %IniLocation%, LastCraft, CraftMacroButton
	}
	
	If VersionURL = "NoURL"
	{
		IniWrite, "https://raw.githubusercontent.com/%GitHub_User%/%GitHub_Repo%/master/latestversion.txt", %IniLocation%, ScriptOptions, UpdateURL
		IniWrite, 3.2.1, %IniLocation%, ScriptOptions, Version
		IniWrite, "https://github.com/%GitHub_User%/%GitHub_Repo%/archive/refs/tags/", %IniLocation%, ScriptOptions, PackageURL
		IniWrite, 1, %IniLocation%, ScriptOptions, AutoUpdate
	}
	
	If Delay = "NoDelay"
	{
		IniWrite, "1500", %IniLocation%, DelaySettings, Delay
		IniWrite, ".3", %IniLocation%, DelaySettings, TextInputDelay
		IniWrite, ".75", %IniLocation%, DelaySettings, MultiCraftDelay
		IniWrite, "2", %IniLocation%, DelaySettings, SitDownDelay
	}
	Return
