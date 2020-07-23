﻿;---------------------------------------------------------------------------------------------------------------------------------------;
; Initialization
;---------------------------------------------------------------------------------------------------------------------------------------;
	#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
	SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
	SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
	#SingleInstance Force

;---------------------------------------------------------------------------------------------------------------------------------------;
; User Variables
;---------------------------------------------------------------------------------------------------------------------------------------;
	;Behaviour
		MonitoredFolder = D:\Downloads
		UnzipTo = D:\Downloads\Compressed
		HowOftenToScanInSeconds = 60 ;How long we wait before re-scanning the folder for any changes.
		ToolTips = 1 ;Show helper popups showing what the program is doing.
		OverWrite = 1 ;Overwrite duplicate files?

	;Zip files
		7ZipLocation = C:\Program Files\7-Zip\7z.exe ;Needed to provide unzipping functionality.
		OpenExtractedZip = False ;Open the folder up after extraction has finished?
		DeleteZipFileAfterExtract = 1 ;Recycle the zip file after a successful extract.
		UnzipSuccessSound = 1 ;Play a jingle when unzipped something.

	;What filetypes belong to what group, and what their folder name should be sorted into.
		FiletypeObjectArray := [] ;Array needs to be initiated first to work.
		PushFiletypeToArray(FiletypeObjectArray,["zip","7z","rar","r00","001"], "Compressed")
		PushFiletypeToArray(FiletypeObjectArray,["jpg","bmp","gif","gifv","webm","png","jpeg","swf","tga","tiff","exr","psd"], "Images")
		PushFiletypeToArray(FiletypeObjectArray,["txt","nfo","rtf","pdf","docx","doc"], "Documents")
		PushFiletypeToArray(FiletypeObjectArray,["mp3","flac","wav"], "Audio")
		PushFiletypeToArray(FiletypeObjectArray,["avi","mpg","mpeg","mov","mp4","mkv","wmv"], "Videos")
		PushFiletypeToArray(FiletypeObjectArray,["exe","msi","jar","cmd","bat","ahk"], "Programs")

;---------------------------------------------------------------------------------------------------------------------------------------;
; Main
;---------------------------------------------------------------------------------------------------------------------------------------;
;Start the folder monitor
	WaitTimeBetweenScans := HowOftenToScanInSeconds * 1000
	SetTimer, SearchFiles, %WaitTimeBetweenScans%
	GoSub,SearchFiles ; Immediately do a scan
return

	SearchFiles:
	Loop, Files, %MonitoredFolder%\*
	{
		DestinationFolder := GetDestination(A_LoopFileFullPath)
		if (DestinationFolder = "Compressed")
			UnZip(A_LoopFileName,A_LoopFileDir,A_LoopFileFullPath)
		else if DestinationFolder
		{
			DestinationFolder := MonitoredFolder . "\" . DestinationFolder
			MakeFolderIfNotExist(DestinationFolder)
			FileMove,%A_LoopFileFullPath%,%DestinationFolder%\*.*,%OverWrite% ; *.* is needed else it could be renamed to no extension! (If dest folder failed)
				if Tooltips
				{
					Tooltip,Moving %A_LoopFileName% > %DestinationFolder%
					SetTimer, RemoveToolTip, 3000
				}
		}
	}
return

;---------------------------------------------------------------------------------------------------------------------------------------;
; Functions
;---------------------------------------------------------------------------------------------------------------------------------------;
	UnZip(FileFullName,Dir,FullPath)
	{
		global 7ZipLocation ;Saves having to re-pass this dir each time you use this function.
		global DeleteZipFileAfterExtract
		global OpenExtractedZip
		global Tooltips
		global UnzipTo
		global UnzipSuccessSound
		
		;Get filename
			StringGetPos,ExtentPos,FileFullName,.,R
			FileName := SubStr(FileFullName,1,ExtentPos)
			if Tooltips
			{
				Tooltip,Unzipping %FileName% > %Dir%\%FileName%
				SetTimer, RemoveToolTip, 3000
			}
			MakeFolderIfNotExist(UnzipTo . "\" . FileName)
			Runwait, "%7ZipLocation%" x "%FullPath%" -o"%UnzipTo%\%FileName%"
		sleep,2000
		
		IfExist %UnzipTo%\%FileName%
		{
			if DeleteZipFileAfterExtract
				Filerecycle, %FullPath%
			if OpenExtractedZip
				run, %UnzipTo%\%FileName%
			if UnzipSuccessSound
				soundplay, *64
		}
		else
			msgbox,,Oh Noes!,Something went wrong and I couldn't unzip %FileName% to %UnzipTo%\%FileName%
	}
	
	;Utilities
		HasVal(haystack, needle)
		{
			for index, value in haystack
				if (value = needle)
					return index
			if !IsObject(haystack)
				throw Exception("Bad haystack!", -1, haystack)
			return 0
		}
		
		MakeFolderIfNotExist(TheFolderDir)
		{
			ifnotexist,%TheFolderDir%
				FileCreateDir,%TheFolderDir%
		}
		
		RemoveToolTip:
			SetTimer, RemoveToolTip, Off
			ToolTip
		return
		
	;Objects
		PushFiletypeToArray(InputArray,FiletypesArray,Destination)
		{
			InputArray.Push(MakeFiletypeObject(FiletypesArray,Destination))
			return InputArray
		}

		MakeFiletypeObject(InputArray,Destination)
		{
			object := []
			object.Extensions := InputArray
			object.Destination := Destination
			return object
		}
		
		GetDestination(TheFile)
		{
			global FiletypeObjectArray
			for i in FiletypeObjectArray
			{
				if HasVal(FiletypeObjectArray[i].Extensions,A_LoopFileExt)
					Destination := FiletypeObjectArray[i].Destination
			}
		return Destination
}

^Esc::ExitApp
