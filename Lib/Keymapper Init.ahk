MCRC=3428FEEC
MVersion=1.0.2

If CustomJoyNamesEnabled = true
{	If CustomJoyNames
	{	Log("Keymapper - Creating Custom Joy Name Array for Name Replacements")
		CustomJoyNameArray := [] ;create array object
		Loop, Parse, CustomJoyNames, \
		{	StringSplit, OutputArray,A_LoopField,|
			;Log(OutputArray1 . " : " . OuputArray2)
			CustomJoyNameArray.Insert(OutputArray1, OutputArray2) ;insert [OEM Name,Custom name] into the array call this array using the oem name to get the custom name.
		}
	} Else
		ScriptError("Custom_Joy_Names_Enabled is set to true and no value was found in Custom_Joy_Names under global settings or system settings.`nPlease disable Custom Joy Names or provide a valid Custom_Joy_Names list." )
}

If JoyIDsEnabled = true
{	Log("Keymapper - Checking for the JoyIDs_Preferred_Controllers key  in " . A_ScriptDir . "\Settings\" . systemName . "\Games JoyIDs.ini under section [" . dbName . "]", 5)
	IniRead, JoyIDsPreferredControllersRom, %A_ScriptDir%\Settings\%systemName%\Games JoyIDs.ini, %dbName%, JoyIDs_Preferred_Controllers ;checking to see if user has per game settings HQ may or may not want to support it but being able to do it per game is important.
	;Converting from rom -> emu -> system -> global to get the correct Preferred controller list.
	JoyIDsPreferredControllersSystem := (If JoyIDsPreferredControllersRom = "ERROR" ? (JoyIDsPreferredControllersSystem) : (JoyIDsPreferredControllersRom))
	JoyIDsPreferredControllers := (If JoyIDsPreferredControllersSystem = "use_global" ? (JoyIDsPreferredControllersGlobal) : (JoyIDsPreferredControllersSystem))

	If JoyIDsPreferredControllers
		LoadPreferredControllers(JoyIDsPreferredControllers)
	Else
		ScriptError("Error: You supplied an empty Preferred Controller List.`nSettings for this can be found under in`n" . emuFile . "`n" . systemName . "\Hyperlaunch.ini`nGlobal HyperLaunch.ini`n`nPlease make sure to include the controller name in this format:`nController Name 1|Controller Name 2|Controller Name 3 . (the numbers are not needed.)")
}

If keymapperEnabled = true
{	If keymapper = xpadder
		keymapperFullPath := CheckFile(xpadderFullPath) ; No need to continue if path set wrong
	Else If ( keymapper = "joytokey" || keymapper = "joy2key" ) {
		keymapperFullPath := CheckFile(joyToKeyFullPath)
		;write location of joytokey.ini to registry because v5.4.2 requires this if profiles are not in same directory as joytokey.exe
		SplitPath, keymapperFullPath,,jtkPath,,jtkName
		jtkIniPath := jtkPath . "\" . jtkName . ".ini"
		RegRead, jtkIniRegPath, HKCU, Software\JoyToKey, IniFilePath
		If ErrorLevel OR (jtkIniRegPath != jtkIniPath) {
			Log("Keymapper - Creating JoyToKey ini registry key for the ini path: " . jtkIniPath)
			RegWrite, REG_SZ, HKCU, Software\JoyToKey, IniFilePath, %jtkIniPath%
		}
		jtkPath := "", jtkName := "", jtkIniPath := "", jtkIniRegPath :=""
	}

	Log("Keymapper - Loading " . keymapper)
	RunKeymapper("load",keymapper)
}

If keymapperAHKMethod = External
{	Log("Keymapper - Loading External AHK Keymapping")
	ahkLauncherFullPath := CheckFile(moduleExtensionsPath . "\AhkLauncher.exe","AhkLauncher.exe is required to use ahk keymaps externally but could not locate it in your module extensions folder: " . moduleExtensionsPath . "\AhkLauncher.exe")
	SplitPath, ahkLauncherFullPath,ahkLauncherExe,ahkLauncherPath
	RunAHKKeymapper("load")	; load rom ahk profile
}
