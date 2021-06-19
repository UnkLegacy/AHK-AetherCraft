# AHK-AetherCraft
A collection of AHK scripts for use for the Jenova Free Company, Aether Craft

## Requirements
- 7-zip is required for Auto Update functionality.  It is a free download that you can get from here: https://www.7-zip.org/
-- Ensure that you add 7z to the Windows PATH variable.  You can check if this is installed correctly by typing "7z" (without quotes) at the command prompt.

## AetherCraft.ini Setup
- Do NOT change anything under the [GameLocation] section unless you know what to put here.
- Change [StaticUserSettings] to your Up, Down, Right, Esc, and Confirm keybinds from FFXIV.
- [LastCraft] is just there to store your previous crafting session.  So if you frequently run the script with the same settings, it will remember them.

## Crafting Specific Macros (Must have FF14 as active Window)
- `F6`  - Opens the Scanning GUI window.
- `F10` - Opens the Crafting GUI window.  *** Warning: Currently only works for 1 button macros ***
- `F12` - Aborts crafting.

### How to use Scanning GUI
- Note: Ensure the Hand is showing on the top most item in the Market Board.
- Total Items - Enter in the Total Number of items in the Market Board Window.  Leave blank for all 100 items.

### How to use Crafting GUI
- Total Crafts - Enter in the number of crafts you would like to make.
- Macro Duration - Enter the duration of the macro (in seconds).  Find this information on FF14 Teamcraft.
- Macro Button - Enter the key where the macro you wish to run resides.  Eg. Numpad5  *** Warning: Do not use Key Combinations, such as Ctrl + 1 ***

## General Macros
- `Ctrl + S` - Saves (S only) and Reloads the Script.  Only works in NotePad++.
- `Ctrl + R` - Reloads the Script.  Only works in NotePad++.