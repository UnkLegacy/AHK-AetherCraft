; Originally created by Staren Alloria.
; Improvements by Lovo'tan Khatshri.

#Persistent ; Keeps script permanently running
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance, Force ; Ensures that there is only a single instance of this script running.
#InstallKeybdHook
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

; Table of Contents:
; 1. Ctrl+S or Ctrl+R - Reload Script.  Only works in NotePad++
; 2. Ctrl+H - Shows the ReadMe file.
; 3. F10 - Launch Craft GUI
; 4. F12 - Stop Crafting Script

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

f10::
; Ctrl+Alt+C - Display crafting window
Gui, Add, Text,, Total Crafts:	; Label for total crafts
Gui, Add, Text,, Macro Duration(sec):	; Label for how long macro takes to run
Gui, Add, Text,, Macro button (eg, Numpad0):  ; Label for which button the crafting macro resides on
Gui, Add, Text,, Confirm Button:   ; Label for the button used to confirm things in the game.
Gui, Add, Edit, vTotal ym  ; The ym option starts a new column of controls.
Gui, Add, Edit, vTime ; Time, in seconds to craft once.
Gui, Add, Edit, vButton ; Macro button
Gui, Add, Edit, vConfirm ; Confirm button
Gui, Add, Button, gCraft, &Craft ; The function Craft will be run when the Craft button is pressed.
Gui, Show,, Macro Settings
Return

Craft:
	Gui, Submit  ; Save the input from the user to each control's associated variable.
	arg1 := "ahk_parent"
	Game := "ahk_exe ffxiv_dx11.exe"
	GameTitle := "FINAL FANTASY XIV"
	
	; Variables
	SleepTime := (Time * 1000)
	Delay = 1500
	Breakloop := false
	
	; Let user know the script is starting
	WinActivate, %GameTitle%
	Sleep, Delay
	Send, /
	Sleep, Delay * .5
	Send, echo Crafting by AHK started. <se.13> {enter}
	Sleep, Delay
	
	Loop, %Total%
	{
	; Check for user to break
	If Breakloop
		Break
	ControlSend, %arg1%, {%Confirm%}, %Game% ; Summon the hand
	Sleep, Delay
	ControlSend, %arg1%, {%Confirm%}, %Game% ; Select the recipe
	Sleep, Delay
	ControlSend, %arg1%, {%Confirm%}, %Game% ; Starts crafting
	Sleep, Delay*2 ; Wait for us to sit down
	
	If Breakloop
		Break
	ControlSend, %arg1%, {%Button%}, %Game% ; Hit your crafting macro button
	If Breakloop
		Break
		
	Sleep, %SleepTime% ; Wait for crafting macro to finish
	}
	
	; Let user know the script is finished
	WinActivate, %GameTitle%
	Sleep, Delay
	Send, /
	Sleep, Delay * .5
	If (Breakloop)
		Send, echo Crafting stopped by user. <se.11>
	Else
		Send, echo Crafting by AHK completed. <se.1>
	Send, {enter}
	
Gui, Destroy
Return

f12::
; Breaks crafting loop
Breakloop := true
TrayTip,, Stopping crafting. Please wait. ,, 18
Return

; Removes any popped up tray tips.
RemoveTrayTip:
	SetTimer, RemoveTrayTip, Off 
	TrayTip 
Return 
